const std = @import("std");

const c = @cImport({
    @cInclude("openssl/asn1.h");
    @cInclude("openssl/bio.h");
    @cInclude("openssl/conf.h");
    @cInclude("openssl/err.h");
    @cInclude("openssl/pem.h");
    @cInclude("openssl/x509.h");
});

const certificate: []const u8 = 
    \\-----BEGIN CERTIFICATE-----
    \\YOURCERTIFICATEHERE
    \\-----END CERTIFICATE-----
;

pub fn main() anyerror!void {
    const openssl_version: [*c]const u8 = c.OPENSSL_VERSION_TEXT;
    std.log.info("{s}", .{openssl_version});

    const settings: ?*const c.OPENSSL_INIT_SETTINGS = null;
    var rc: c_int = c.OPENSSL_init_crypto(
        c.OPENSSL_INIT_ADD_ALL_CIPHERS
        | c.OPENSSL_INIT_ADD_ALL_DIGESTS
        | c.OPENSSL_INIT_LOAD_CRYPTO_STRINGS,
        settings
    );
    if (rc == 0) {
        std.log.err("openssl: failed to initialize openssl", .{});
        std.process.exit(1);
    }

    var buf: ?*c.BIO = c.BIO_new_mem_buf(certificate.ptr, certificate.len);
    if (buf == null) {
        std.log.err("openssl: bio: failed to create buffer for certificate", .{});
        std.process.exit(1);
    }
    defer _ = c.BIO_free(buf); // TODO handle rc. 1==success, 0==failure

    const x509: ?*c.X509 = c.PEM_read_bio_X509_AUX(buf, null, null, null);
    if (x509 == null) {
        std.log.err("openssl: pem: failed to certificate from buffer", .{});
        std.process.exit(1);
    }
    defer _ = c.X509_free(x509);

    const subject_name: ?*c.X509_NAME = c.X509_get_subject_name(x509);
    _ = c.X509_NAME_print_ex_fp(c.stdout, subject_name, 0, 0);
    _ = c.puts("");
}
