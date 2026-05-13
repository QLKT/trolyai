/**
 * AI SISP Pro - Core Logic
 */

import "whatwg-fetch";
import marked from "marked";
import { HostManager } from "./HostManager";
import { FileManager } from "./FileManager";

const PROVIDERS = {
    ollama: {
        baseUrl: "http://localhost:11434", // Direct connection to Ollama
        endpoint: "/api/chat",
        modelName: "gemma4:e4b",
    },
    lmstudio: {
        baseUrl: "http://localhost:1234",   // Direct connection to LM Studio
        endpoint: "/v1/chat/completions",
        modelName: "local-model",
    },
};

// Configure Marked for better chat rendering
if (typeof marked !== "undefined") {
    marked.setOptions({
        breaks: true,
        gfm: true
    });
}

class AISISPPro {
    constructor() {
        this.hostManager = new HostManager();
        this.fileManager = new FileManager();
        this.currentProvider = "ollama";
        this.isGenerating = false;
        
        this.elements = {
            chatContainer: document.getElementById("chat-container"),
            userInput: document.getElementById("user-input"),
            generateBtn: document.getElementById("generate-btn"),
            providerSelect: document.getElementById("ai-provider-select"),
            statusBadge: document.getElementById("connection-status"),
            hostIndicator: document.getElementById("host-indicator"),
            notification: document.getElementById("status-notification")
        };

        // Set initial status
        this.elements.statusBadge.textContent = "Kết nối: Chờ chọn AI...";
        this.elements.statusBadge.style.color = "var(--text-secondary)";

        this.init();
    }

    async init() {
        // Initialize Host
        const host = await this.hostManager.initialize();
        this.elements.hostIndicator.textContent = `MODE: ${host.toUpperCase()}`;
        
        // Event Listeners
        this.elements.generateBtn.addEventListener("click", () => this.handleGenerate());
        this.elements.userInput.addEventListener("keydown", (e) => {
            if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                this.handleGenerate();
            }
        });
        
        this.elements.providerSelect.addEventListener("change", (e) => {
            this.currentProvider = e.target.value;
            this.showNotification(`Đã đổi sang: ${this.currentProvider.toUpperCase()}`);
            this.testConnection(); // Test connection when provider is changed
        });

        // Setup Drop Zone
        this.fileManager.setupDropZone(this.elements.chatContainer, (file) => this.handleFileDrop(file));
        
        // Initial connection test for default provider
        this.testConnection();
    }

    async testConnection() {
        this.elements.statusBadge.textContent = "Kết nối: Đang thử...";
        this.elements.statusBadge.style.color = "var(--text-secondary)";
        
        try {
            const provider = PROVIDERS[this.currentProvider];
            const url = this.currentProvider === "ollama" 
                ? `${provider.baseUrl}/api/tags` 
                : "/v1/models";
            
            console.log(`[AISISP] Testing connection to: ${url}`);
            const response = await fetch(url);
            
            if (response.ok) {
                this.elements.statusBadge.textContent = "Kết nối: OK ✅";
                this.elements.statusBadge.style.color = "var(--accent)";
            } else {
                throw new Error(`HTTP ${response.status}`);
            }
        } catch (e) {
            console.error("[AISISP] Connection failed:", e);
            this.elements.statusBadge.textContent = `Kết nối: LỖI (${e.message}) ❌`;
            this.elements.statusBadge.style.color = "var(--danger)";
        }
    }

    async handleGenerate() {
        if (this.isGenerating) return;

        const userInput = this.elements.userInput.value.trim();
        const contextText = await this.hostManager.getContextText();
        
        if (!userInput && !contextText) {
            this.showNotification("Vui lòng nhập yêu cầu hoặc chọn văn bản.");
            return;
        }

        // Combine command with context
        let prompt = "";
        let displayMsg = "";

        if (userInput && contextText) {
            prompt = `Yêu cầu: ${userInput}\n\nNội dung văn bản:\n${contextText}`;
            displayMsg = userInput; // Show only command in chat for cleaner UI
        } else if (userInput) {
            prompt = userInput;
            displayMsg = userInput;
        } else {
            prompt = contextText;
            displayMsg = "[Xử lý văn bản đã chọn]";
        }

        this.elements.userInput.value = "";
        this.addMessage("user", displayMsg);
        
        try {
            this.isGenerating = true;
            this.elements.generateBtn.disabled = true;
            
            const aiMessage = this.addMessage("ai", "");
            const aiContentElement = aiMessage.querySelector(".content");
            
            let fullResponse = "";
            const stream = this.getAIStream(prompt);
            
            for await (const chunk of stream) {
                fullResponse += chunk;
                // Render as markdown during streaming if possible
                if (typeof marked === "function") {
                    aiContentElement.innerHTML = marked(fullResponse);
                } else {
                    aiContentElement.textContent = fullResponse;
                }
                this.elements.chatContainer.scrollTop = this.elements.chatContainer.scrollHeight;
            }

            // After generation, if in Office, offer insertion options
            if (this.hostManager.isOffice()) {
                const actionsContainer = document.createElement("div");
                actionsContainer.className = "message-actions";
                actionsContainer.style.display = "flex";
                actionsContainer.style.gap = "8px";
                actionsContainer.style.marginTop = "12px";
                actionsContainer.style.flexWrap = "wrap";

                const btnConfigs = [
                    { text: "📥 Chèn cuối", action: "end", title: "Chèn vào cuối tài liệu" },
                    { text: "🔄 Thay thế", action: "replace", title: "Thay thế đoạn đang bôi đen" },
                    { text: "✨ Sửa & Bôi vàng", action: "highlight", title: "Sửa lỗi chính tả & bôi vàng" }
                ];

                btnConfigs.forEach(cfg => {
                    const btn = document.createElement("button");
                    btn.textContent = cfg.text;
                    btn.title = cfg.title;
                    btn.className = "action-btn"; 
                    btn.onclick = async () => {
                        try {
                            const contentToInsert = (typeof marked === "function") ? marked(fullResponse) : fullResponse;
                            await this.hostManager.insertContent(contentToInsert, cfg.action);
                            this.showNotification(`Đã ${cfg.text.toLowerCase()}`);
                        } catch (e) {
                            this.showNotification("Lỗi chèn văn bản: " + e.message);
                        }
                    };
                    actionsContainer.appendChild(btn);
                });

                aiMessage.appendChild(actionsContainer);
            }

        } catch (error) {
            console.error(error);
            this.addMessage("ai", `❌ Lỗi: ${error.message}`);
        } finally {
            this.isGenerating = false;
            this.elements.generateBtn.disabled = false;
        }
    }

    addMessage(role, text) {
        const msgDiv = document.createElement("div");
        msgDiv.className = `message ${role}`;
        
        const content = document.createElement("div");
        content.className = "content";
        
        if (role === "ai" && typeof marked !== "undefined") {
            content.innerHTML = marked.parse(text);
        } else {
            content.textContent = text;
        }
        
        msgDiv.appendChild(content);
        this.elements.chatContainer.appendChild(msgDiv);
        this.elements.chatContainer.scrollTop = this.elements.chatContainer.scrollHeight;
        return msgDiv;
    }

    async handleFileDrop(file) {
        this.showNotification(`Đang đọc file: ${file.name}`);
        try {
            let text = "";
            if (file.type === "application/pdf") {
                text = await this.fileManager.extractTextFromPDF(file);
            } else {
                text = await file.text();
            }
            
            this.addMessage("user", `[Phân tích file: ${file.name}]\n\n${text.substring(0, 500)}...`);
            this.elements.userInput.value = `Hãy tóm tắt nội dung file ${file.name} này giúp tôi.`;
        } catch (e) {
            this.showNotification(`Lỗi đọc file: ${e.message}`);
        }
    }

    async* getAIStream(prompt) {
        const provider = PROVIDERS[this.currentProvider];
        const url = this.currentProvider === "ollama" 
            ? `${provider.baseUrl}/api/chat` 
            : "/v1/chat/completions";

        const payload = this.currentProvider === "ollama" ? {
            model: provider.modelName,
            messages: [{ role: "user", content: prompt }],
            stream: true
        } : {
            model: provider.modelName,
            messages: [{ role: "user", content: prompt }],
            stream: true
        };

        const response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload)
        });

        if (!response.ok) throw new Error(`API Error: ${response.status}`);

        if (!response.body) {
            const fullText = await response.text();
            const lines = fullText.split("\n");
            for (const line of lines) {
                const trimmed = line.trim();
                if (!trimmed) continue;
                yield* this._parseAIChunk(trimmed);
            }
            return;
        }

        const reader = response.body.getReader();
        const decoder = (typeof TextDecoder !== "undefined") ? new TextDecoder() : null;
        let buffer = "";

        while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            let chunk = "";
            if (decoder) {
                chunk = decoder.decode(value, { stream: true });
            } else {
                // Fallback for missing TextDecoder (very rare if fetch exists but body exists)
                chunk = String.fromCharCode.apply(null, new Uint8Array(value));
            }

            buffer += chunk;
            const lines = buffer.split("\n");
            buffer = lines.pop() || "";

            for (const line of lines) {
                const trimmed = line.trim();
                if (!trimmed) continue;
                yield* this._parseAIChunk(trimmed);
            }
        }
    }

    * _parseAIChunk(trimmed) {
        if (this.currentProvider === "ollama") {
            try {
                const data = JSON.parse(trimmed);
                if (data.message && data.message.content) yield data.message.content;
            } catch (e) {}
        } else {
            if (trimmed.startsWith("data: ")) {
                const dataStr = trimmed.slice(6);
                if (dataStr === "[DONE]") return;
                try {
                    const data = JSON.parse(dataStr);
                    if (data.choices && data.choices[0].delta && data.choices[0].delta.content) {
                        yield data.choices[0].delta.content;
                    }
                } catch (e) {}
            }
        }
    }

    showNotification(msg) {
        this.elements.notification.textContent = msg;
        this.elements.notification.style.display = "block";
        setTimeout(() => {
            this.elements.notification.style.display = "none";
        }, 3000);
    }
}

// Start the app
window.addEventListener("load", () => {
    new AISISPPro();
});
