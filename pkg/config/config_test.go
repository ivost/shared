package config_test

import (
	"testing"

	"github.com/ivost/sandbox/myservice/config"
	"github.com/stretchr/testify/require"
)

const configFile = "./config.yaml"

func TestConfig(t *testing.T) {
	exp := &config.Config{
		GrpcAddr: "0.0.0.0:52053",
		RestAddr: "0.0.0.0:8081",
		Secure:   0,
		CertFile: "../ssl/server1.crt",
		KeyFile:  "../ssl/server1.pem",
	}
	cfg := config.New(configFile)
	require.NotNil(t, cfg)
	require.EqualValues(t, exp, cfg)
}
