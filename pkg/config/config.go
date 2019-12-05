package config

import (
	"flag"
	"log"
	"os"

	mconfig "github.com/micro/go-micro/config"
	"github.com/micro/go-micro/config/source/env"
	mflag "github.com/micro/go-micro/config/source/flag"
)

// configuration
type Config struct {
	GrpcAddr string
	RestAddr string
	Secure   int
	CertFile string
	KeyFile  string
}

const DefaultGrpc = "0.0.0.0:52052"
const DefaultRest = "0.0.0.0:8080"
const DefaultConfigFile = "./config.yaml"
const DefaultCertFile = "./ssl/server.crt"
const DefaultKeyFile = "./ssl/server.pem"

func DefaultConfig() *Config {
	return &Config{
		GrpcAddr: DefaultGrpc,
		RestAddr: DefaultRest,
		CertFile: DefaultCertFile,
		KeyFile:  DefaultKeyFile,
	}
}

func New(yamlFile string) *Config {
	if yamlFile == "" {
		return DefaultConfig()
	}
	conf := DefaultConfig()
	configFile := yamlFile
	flag.StringVar(&configFile, "config", DefaultConfigFile, "config file")
	flag.StringVar(&conf.GrpcAddr, "grpc", DefaultGrpc, "grpc address")
	flag.StringVar(&conf.RestAddr, "rest", DefaultRest, "rest address")
	flag.IntVar(&conf.Secure, "secure", 0, "secure: 0=no TLS, 1=server, 2=mTLS")
	flag.Parse()
	//https://micro.mu/docs/go-config.html
	flags := mflag.NewSource( /* mflag.IncludeUnset(true), */ )
	flags.Read()
	err := mconfig.Load(
		// base config from env
		env.NewSource(),
		// flag override
		flags,
	)
	_ = mconfig.Scan(conf)
	if _, err = os.Stat(configFile); err != nil {
		return conf
	}
	log.Printf("Using config file %v", configFile)
	mconfig.LoadFile(configFile)
	_ = mconfig.Scan(conf)
	return conf
}
