{
  lightdm-kde-greeter,
  lib,
  fetchFromGitHub,
  nix-update-script,
  linkFarm,
  pkg-config,
  kdePackages,
  lightdm_qt,
  qt6,
  gtk2,
  libGL,
  nixos-artwork,
  wallpaper ? nixos-artwork.wallpapers.nineish-catppuccin-mocha.passthru.kdeFilePath,
}:
kdePackages.mkKdeDerivation rec {
  pname = "lightdm-kde-greeter";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "KDE";
    repo = "lightdm-kde-greeter";
    rev = "v${version}";
    hash = "sha256-I76foe0Y6nxSTwyiHE98ZlBlU4mBVtpN+6t/wkGw2JM=";
  };

  extraBuildInputs = with kdePackages; [
    lightdm_qt
    gtk2
    qt6.full

    kauth
    kcmutils
    kcmutils
    kconfig
    kconfigwidgets
    kcoreaddons
    kdeclarative
    ki18n
    kiconthemes
    kirigami
    kpackage
    kservice
    ksvg
    libplasma
    networkmanager-qt
    plasma-workspace
    qtshadertools
    qtshadertools
    qtsvg
    qtvirtualkeyboard
  ];

  extraNativeBuildInputs = [
    pkg-config
  ];

  dontFixCmake = false;
  dontUseCmakeConfigure = true;
  buildPhase = ''
    cmake -G Ninja -DGREETER_IMAGES_DIR=$out/images -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_WITH_QT6=ON -DQT_MAJOR_VERSION=6 -DLIGHTDM_CONFIG_DIR=$out -DGREETER_DEFAULT_WALLPAPER=${wallpaper} -DDATA_INSTALL_DIR=$out/share .
  '';

  # doesnt work for some reason
  # extraCmakeFlags = [
  #   "-DGREETER_IMAGES_DIR=$out/images"
  #   "-DBUILD_TESTING=ON"
  #   "-DCMAKE_BUILD_TYPE=Debug"
  #   "-DCMAKE_INSTALL_PREFIX=$out"
  #   "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
  #   "-DBUILD_WITH_QT6=ON"
  #   "-DLIGHTDM_CONFIG_DIR=$out"
  #   "-DGREETER_DEFAULT_WALLPAPER=/mnt/potd/wallpaper.jpg"
  #   "-DDATA_INSTALL_DIR=$out/share"
  # ];

  postInstall = ''
    substituteInPlace "$out/share/xgreeters/lightdm-kde-greeter.desktop" \
    --replace "Exec=lightdm-kde-greeter" "Exec=$out/bin/lightdm-kde-greeter"
  '';

  postFixup = ''
    patchelf \
    --add-needed ${lib.getLib libGL}/lib/libGL.so.1 \
    $out/bin/lightdm-kde-greeter

    patchelf \
    --add-needed ${lib.getLib libGL}/lib/libGL.so.1 \
    $out/bin/lightdm-kde-greeter-rootimage

    substituteInPlace "$out/share/systemd/user/lightdm-kde-greeter-wifikeeper.service" \
    --replace "ExecStart=/lightdm-kde-greeter-wifikeeper" "ExecStart=$out/bin/lightdm-kde-greeter-wifikeeper"

    substituteInPlace "$out/share/dbus-1/system-services/org.kde.kcontrol.kcmlightdm.service" \
    --replace "Exec=lib64/libexec/kcmlightdmhelper" "Exec=$out/lib64/libexec/kcmlightdmhelper"

    mkdir $out/lib/qt-6
    mv $out/lib/plugins $out/lib/qt-6/
  '';

  passthru.xgreeters = linkFarm "lightdm-kde-greeter-xgreeters" [
    {
      path = "${lightdm-kde-greeter}/share/xgreeters/lightdm-kde-greeter.desktop";
      name = "lightdm-kde-greeter.desktop";
    }
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Login screen using the LightDM framework.";
    longDescription = ''
      Login screen using the LightDM framework.
          * "LightDM project": https://launchpad.net/lightdm
          * "Bug Tracker": https://bugs.kde.org/describecomponents.cgi?product=lightdm
    '';
    homepage = "https://invent.kde.org/plasma/lightdm-kde-greeter";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
