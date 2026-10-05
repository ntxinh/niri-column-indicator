```sh
cd ~/.config/DankMaterialShell/plugins/
gh clone repo ntxinh/niri-column-indicator
```

# Kích hoạt Plugin

Bây giờ bạn đã tạo xong các tệp, hãy làm theo các bước sau để kích hoạt plugin:

- Quét Plugin: Mở DMS Settings → Plugins và nhấn nút "Scan for Plugins".
- Thêm vào thanh Bar: Sau khi quét, plugin `Niri Column Indicator` sẽ xuất hiện trong danh sách. Bạn cần thêm nó vào thanh bar. Trong DMS Settings, vào phần Bar (hoặc DankBar), tìm đến mục Widgets và kéo hoặc thêm widget `niri-column-indicator` vào một trong các phần (Left, Center, Right) của thanh bar.
- Khởi động lại DMS (nếu cần): Đôi khi bạn có thể cần khởi động lại DMS để các thay đổi có hiệu lực. Bạn có thể làm điều này bằng cách chạy lệnh `dms ipc call plugins reload niri-column-indicator` hoặc đơn giản là đăng xuất và đăng nhập lại

# Mẹo và Gỡ lỗi

- Kiểm tra dữ liệu thô: Để chắc chắn Niri đang trả về dữ liệu như mong đợi, bạn có thể chạy lệnh `niri msg --json windows | jq` trong terminal. Nó sẽ hiển thị JSON được định dạng, giúp bạn dễ dàng kiểm tra các trường như `app_id` và `pos_in_scrolling_layout`

```sh
dms ipc call widget list
dms run
dms restart
```
