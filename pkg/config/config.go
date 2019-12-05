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
	log.Printf("New config, yamlFile: %v\n", yamlFile)
	conf := DefaultConfig()
	configFile := yamlFile

	RegStringVar(&configFile, "config", DefaultConfigFile, "config file")

	RegStringVar(&conf.GrpcAddr, "grpc", DefaultGrpc, "grpc address")
	RegStringVar(&conf.RestAddr, "rest", DefaultRest, "rest address")
	RegIntVar(&conf.Secure, "secure", 0, "secure: 0=no TLS, 1=server, 2=mTLS")
	flag.Parse()
	//https://micro.mu/docs/go-config.html
	flags := mflag.NewSource( /* mflag.IncludeUnset(true), */ )
	flags.Read()

	err := mconfig.Load(
		// base config from env
		env.NewSource(),
		// flag override
		//flags,
	)
	_ = mconfig.Scan(conf)
	if yamlFile == "" {
		configFile = GetStringFlag("config")
	} else {
		configFile = yamlFile
	}

	if _, err = os.Stat(configFile); err != nil {
		log.Printf("Config file %v not found", configFile)
		return conf
	}
	log.Printf("Reading config file %v", configFile)
	mconfig.LoadFile(configFile)
	_ = mconfig.Scan(conf)
	//log.Printf("config: %+v", conf)
	return conf
}

func RegStringVar(p *string, name string, value string, usage string) {
	if flag.Lookup(name) == nil {
		flag.StringVar(p, name, value, usage)
	}
}

func GetStringFlag(name string) string {
	return flag.Lookup(name).Value.(flag.Getter).Get().(string)
}

func RegIntVar(p *int, name string, value int, usage string) {
	if flag.Lookup(name) == nil {
		flag.IntVar(p, name, value, usage)
	}
}

func GetIntFlag(name string) int {
	return flag.Lookup(name).Value.(flag.Getter).Get().(int)
}
