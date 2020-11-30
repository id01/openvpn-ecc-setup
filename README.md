Setting up OpenVPN was painful. So I'm leaving this here just in case anyone (mainly myself) wants to do it again.

This is a fully fleged OpenVPN configuation setup script with:
* ECC (using secp521r1)
* AES-256-CBC
* TLS authentication
* DHCP
* Embedded certificate/key files in ovpn

How to set up:
* Download OpenSSL and OpenVPN
* Edit client_template.ovpn, replacing remote with your server's IP or URL
* Edit client_template.ovpn and server_template.ovpn with the settings you like
* Run ./setup_ca.sh to get CA, server cert/key/ovpn, and client cert/key/ovpn
* Upload server.conf to server in /etc/openvpn.
* Create /etc/openvpn/clients (using mkdir)
* Add iptables forwarding rules. Save them somewhere to apply every boot.
	* `iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISTHED -j ACCEPT`
	* `iptables -A FORWARD -s 10.8.0.0/24 -i tun0 -o eth0 -m conntrack --ctstate NEW -j ACCEPT`
	* `iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE`

