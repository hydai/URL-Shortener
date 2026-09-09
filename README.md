# URL-Shortener
URL 縮網址服務，以方便管理自己的演講投影片與其他需要分享的資料，受 https://github.com/sitcon-tw/URL-Shortener 啟發

## 新增短網址

1. 複製 `_redirects/template.md` 為 `_redirects/<slug>.md`。slug 就是網址 `https://url.hyd.ai/<slug>/`，一律用小寫：GitHub Pages 區分大小寫，小寫最不容易打錯。
2. 填好三個欄位：`title` 與 `description` 是分享時的預覽標題與描述，`redirect_to` 必須是完整的 http(s) 網址。
3. push 到 `main`，GitHub Actions 會先驗證所有 entry 再部署。

本機檢查：

```bash
.github/scripts/validate-redirects.sh
bundle exec jekyll build --strict_front_matter
```
