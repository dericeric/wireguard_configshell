serpukey=$(cat ./wg/sprivatekey)
ser=network_wg
echo >>$ser
echo "config interface 'wg0'">>$ser
echo "        option proto 'wireguard'">>$ser
echo "        option listen_port '23456'">>$ser
echo "        list addresses '10.0.0.1/24'">>$ser
echo "        option private_key" $serpukey>>$ser
