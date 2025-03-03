{pkgs, ...}: {
  default = pkgs.mkShell {
    packages = with pkgs; [
      zbar
      droidcam
      v4l-utils

      gnupg
      paperkey

      xxd
      qrencode
    ];
    shellHook = ''
      echo "	To recover: "
      echo "		If you can scan through zbarcam:"
      echo "			zbarcam -1 --raw -Sbinary > paperkey.raw"
      echo ""
      echo "		If you scanned a QR code as HEX:"
      echo "			xxd -r -p paperkey.txt > paperkey.raw"
      echo ""
      echo "		gpg --recv-keys 0x7A984C8207ADBA51"
      echo "		gpg --export 0x7A984C8207ADBA51 > pubkey.gpg"
      echo "		paperkey --pubring pubkey.gpg --secrets paperkey.raw | gpg --import"
      echo ""
      echo "	To create:"
      echo "		gpg --export-secret-key key-id | paperkey --output-type raw | qrencode --8bit --output secret-key.qr.png"
    '';
  };
}
