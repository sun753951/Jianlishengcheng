# 简历导出辅助脚本
$hdc = "E:\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe"

Write-Host "设置 PC->模拟器 端口转发 (8888)..." -ForegroundColor Cyan
& $hdc fport tcp:8888 tcp:8888

Write-Host "设置 模拟器->PC 反向端口转发 (8000)..." -ForegroundColor Cyan
& $hdc rport tcp:8000 tcp:8000

Write-Host "完成！" -ForegroundColor Green
Write-Host "  模拟器内 App 通过 127.0.0.1:8000 访问 PC 后端" -ForegroundColor Gray
Write-Host "  PC 浏览器通过 localhost:8888 下载 PDF" -ForegroundColor Gray
Write-Host "按任意键退出..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
