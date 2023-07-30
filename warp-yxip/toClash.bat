@echo off
setlocal EnableDelayedExpansion

set "input_file=result.csv"

rem 定义变量来保存符合条件的 IP:PORT
set "matching_ip_ports="

rem 逐行处理输入文件
for /f "skip=1 tokens=1,2,3 delims=, " %%a in ('type "%input_file%"') do (
set "ip_port=%%a"
set "loss=%%b"
set "delay=%%c"

rem 输出调试信息到控制台和日志文件
echo Processing IP:PORT !ip_port! with LOSS !loss! and DELAY !delay!...
rem 判断当前行的loss是否为0
if "!loss: =!"=="0.00%%" (
rem 将符合条件的IP:PORT添加到变量中
set "matching_ip_ports=!matching_ip_ports! !ip_port!"
)
)

rem 打印收集到的符合条件的 IP:PORT
echo Matching IP:PORTs: !matching_ip_ports!

rem 遍历收集到的 IP:PORT 并格式化为 YAML 格式
echo proxies: > output.yaml
for %%i in (%matching_ip_ports%) do (
    for /f "tokens=1,2 delims=:" %%a in ("%%i") do (
    echo     - { name: %%i, type: wireguard, server: %%a, port: %%b, ip: 172.16.0.2, public-key: bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=, private-key: AD71vBuQE+r1bQGUKraf+T9AZ06bvMZpsMlpZjLpFVI=, mtu: 1280, udp: true } >> output.yaml
    )
)

echo proxy-groups: >> output.yaml
echo     - name: warp >> output.yaml
echo       type: select >> output.yaml
echo       proxies: >> output.yaml
echo         - 自动选择 >> output.yaml
echo     - name: 自动选择 >> output.yaml
echo       type: url-test >> output.yaml
echo       proxies: >> output.yaml
for %%i in (!matching_ip_ports!) do (
echo         - %%i >> output.yaml
)
echo       url: 'http://www.gstatic.com/generate_204' >> output.yaml
echo       interval: 86400 >> output.yaml

rem 将clash_temp.yaml 文件并将新内容追加到文件中
type clash_temp.yaml >> output.yaml
endlocal