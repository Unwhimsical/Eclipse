package mitm

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/tls"
	"crypto/x509"
	"crypto/x509/pkix"
	"math/big"
	"time"
)

// getCert returns a TLS certificate for the host, signed by the CA.
// Certificates are cached.
func (p *Proxy) getCert(host string) (*tls.Certificate, error) {
	if v, ok := p.certCache.Load(host); ok {
		return v.(*tls.Certificate), nil
	}
	cert, err := p.generateCert(host)
	if err != nil {
		return nil, err
	}
	p.certCache.Store(host, cert)
	return cert, nil
}

func (p *Proxy) generateCert(host string) (*tls.Certificate, error) {
	if p.caCert == nil || p.caKey == nil {
		return nil, errNoCA
	}
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		return nil, err
	}
	serial, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		return nil, err
	}
	template := x509.Certificate{
		SerialNumber: serial,
		Subject: pkix.Name{
			CommonName: host,
		},
		NotBefore:             time.Now().Add(-time.Hour),
		NotAfter:              time.Now().AddDate(1, 0, 0),
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageKeyEncipherment,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		DNSNames:              []string{host},
	}
	der, err := x509.CreateCertificate(rand.Reader, &template, p.caCert, &key.PublicKey, p.caKey)
	if err != nil {
		return nil, err
	}
	cert := &tls.Certificate{
		Certificate: [][]byte{der},
		PrivateKey:  key,
		Leaf:        &template,
	}
	return cert, nil
}

var errNoCA = errorString("mitm: no CA configured")

type errorString string

func (e errorString) Error() string { return string(e) }
