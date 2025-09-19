# SSL Expiry Checker 
```chmod +x ssl-chk.sh```
##### <i>hosts list</i>
```
rr93.my.id        443
google.com        443
drive.google.com  443
mail.yahoo.com    443
github.com        443
linkedin.com      443
tokopedia.com     443
plazania.com      443
```
### Run script for multi host
```./ssl-chk.sh -f hosts```

<img width="1016" height="243" alt="image" src="https://github.com/user-attachments/assets/16e40d81-8086-4a4c-8bcf-65327d3c0684" />

### Run script for single host

```./ssl-chk.sh -n rr93.my.id -p 443```
<img width="1018" height="137" alt="image" src="https://github.com/user-attachments/assets/2de7ed4b-fa3d-4ac0-bee0-ecde593087dd" />