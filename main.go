package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net"
	"net/http"
	"os"
)

func main() {
	// 1.创建路由
	r := gin.Default()
	// 2.绑定路由规则，执行的函数
	// gin.Context，封装了request和response
	r.GET("/", func(c *gin.Context) {
		//ip := os.Getenv("CONTAINER_IP")
		ip := getContainerIP()
		image := getContainerImage()
		c.String(http.StatusOK, fmt.Sprintf("hello world: [ip]%v, [image]%v", ip, image))
	})
	// 3.监听端口，默认在8080
	// Run("里面不指定端口号默认为8080")
	r.Run(":8000")
}

const (
	UNKNOWN = "unknown"
)

var containerIp string

func getContainerIP() string {
	if containerIp != "" {
		return containerIp
	}
	// 优先从环境变量获取
	if containerIp = os.Getenv("POD_IP"); containerIp != "" {
		return containerIp
	}
	if containerIp = os.Getenv("CONTAINER_IP"); containerIp != "" {
		return containerIp
	}

	// 直接获取eth0
	if eth0, err := net.InterfaceByName("eth0"); err == nil {
		if addrs, err := eth0.Addrs(); err == nil {
			for _, addr := range addrs {
				if ipNet, ok := addr.(*net.IPNet); ok {
					if ip := ipNet.IP.To4(); ip != nil && !ip.IsLoopback() {
						containerIp = ip.String()
						return containerIp
					}
				}
			}
		}
	}

	// 遍历所有接口
	ifaces, err := net.Interfaces()
	if err == nil {
		for _, iface := range ifaces {
			if iface.Flags&net.FlagLoopback != 0 || iface.Flags&net.FlagUp == 0 {
				continue
			}
			addrs, err := iface.Addrs()
			if err != nil {
				continue
			}

			for _, addr := range addrs {
				if ipNet, ok := addr.(*net.IPNet); ok {
					if ip := ipNet.IP.To4(); ip != nil && !ip.IsLoopback() {
						containerIp = ip.String()
						return containerIp
					}
				}
			}
		}
	}

	containerIp = UNKNOWN
	return containerIp
}

func getContainerImage() string {
	image := os.Getenv("GIT_COMMIT")
	if image != "" {
		return image
	}

	return UNKNOWN
}
