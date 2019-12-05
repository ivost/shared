package system

import (
	"net"
	"strings"
)

func MyIP() string {
	ifaces, err := net.Interfaces()
	// handle err
	_ = err
	for _, i := range ifaces {
		addrs, err := i.Addrs()
		// handle err
		_ = err
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			if ip == nil {
				continue
			}
			s := ip.String()
			if strings.Contains(s, ":") {
				continue
			}
			if s == "127.0.0.1" {
				continue
			}
			//log.Printf("addr: %v", ip)
			return s
		}
	}
	return ""
}
