{
  flake.modules.nixos.hub =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # copyparty
        copyparty

        # own additions (not by 9001)
        libarchive
        neovim
        nnn
        openssl
        procs
        progress
        screen
        websocat
        yazi-unwrapped
        zellij

        # chat
        irssi

        # programming
        (python3.withPackages (p: with p; [ pillow ]))
        sc-im
        sqlite
        vim

        # disks
        ddrescue
        dmraid
        lvm2
        nbd
        partclone
        testdisk

        # fileinfo
        file
        hexdump
        hexyl

        # fs
        btrfs-progs
        cryptsetup
        dosfstools
        exfatprogs
        fuse
        fuse3
        mtools
        unionfs-fuse
        ntfs3g
        squashfsTools
        sshfs
        xfsprogs

        # hardware
        dmidecode
        efibootmgr
        efivar
        libcpuid
        lm_sensors
        lshw
        mokutil
        nvme-cli
        pciutils
        sbsigntool
        smartmontools
        usbutils

        # media
        cdparanoia
        fbida
        ffmpeg
        sox

        # network
        apacheHttpd
        bmon
        ethtool
        ipcalc
        iperf
        iproute2
        iputils
        mtr
        nmap
        # pingu # TODO: broken
        proxychains-ng
        socat
        tcpdump
        inetutils
        ttyd

        # com/de
        p7zip
        brotli
        bzip2
        gzip
        lzo
        pigz
        gnutar
        xz
        zstd

        # perf
        htop
        procps

        # textmod (?)
        jq
        less
        patch
        xxd

        # xfer
        aria2
        curl
        rsync

        # misc
        chntpw
        psmisc
        pv
        sshpass
        strace
        time
        tmux
        util-linux
        w3m
        xorriso
        xxHash
      ];
    };
}
