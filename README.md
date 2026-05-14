# Trợ lý AI cho Office
Trợ lý AI cho Office viết bởi P.QLKT Viện QHXDMN năm 2026
# Cách cài đặt:
- Cài đặt LM Studio hoặc Ollama, download 1 model và load model. Cấu hình AI Server (Rất Quan Trọng)
 + Nếu dùng Ollama: Chạy file SETUP-OLLAMA-CORS.bat bằng quyền Admin (chạy 1 lần duy nhất). Nó sẽ cấu hình tự động biến môi trường OLLAMA_ORIGINS="https://qlkt.github.io" và khởi động lại Ollama.
 + Nếu dùng LM Studio: Mở LM Studio → Developer (Server) → Bật tùy chọn "CORS" lên là xong.
- Chuẩn bị bộ file: manifest.xml, INSTALL.bat (để đăng ký với Office), UNINSTALL.bat (để gỡ cài đặt), SETUP-OLLAMA-CORS.bat (để cấu hình nếu họ xài Ollama).
- Chạy INSTALL.bat với quyền admin
- Mở Words, hoặc Excel, hoặc PPT ->Insert/My addins/Shared folder->chọn Trợ lý AI-Add-> Chạy Home/Mở AI->Chọn Ollama (local) hoặc LMstudio (local) để sử dụng AI
- Chạy UNINSTALL.bat để xóa cài đặt
- Nếu dùng Ollama thì chạy SETUP-OLLAMA-CORS.bat
