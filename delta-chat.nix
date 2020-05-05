# COPYRIGHT
# This nix file is based on the official signal-desktop.nix file from nixos
# NixOS/nixpkgs pkgs/applications/networking/instant-messengers/signal-desktop/default.nix

# Copyright (c) 2003-2020 Eelco Dolstra and the Nixpkgs/NixOS contributors

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ stdenv, lib, fetchurl, autoPatchelfHook, dpkg, wrapGAppsHook, nixosTests
, gnome2, gtk3, atk, at-spi2-atk, cairo, pango, gdk-pixbuf, glib, freetype, fontconfig
, dbus, libX11, xorg, libXi, libXcursor, libXdamage, libXrandr, libXcomposite
, libXext, libXfixes, libXrender, libXtst, libXScrnSaver, nss, nspr, alsaLib
, cups, expat, systemd, libnotify, libuuid, at-spi2-core, libappindicator-gtk3
# Unfortunately this also overwrites the UI language (not just the spell
# checking language!):
, hunspellDicts, spellcheckerLanguage ? null # E.g. "de_DE"
# For a full list of available languages:
# $ cat pkgs/development/libraries/hunspell/dictionaries.nix | grep "dictFileName =" | awk '{ print $3 }'
}:

let
  customLanguageWrapperArgs = (with lib;
    let
      # E.g. "de_DE" -> "de-de" (spellcheckerLanguage -> hunspellDict)
      spellLangComponents = splitString "_" spellcheckerLanguage;
      hunspellDict = elemAt spellLangComponents 0 + "-" + toLower (elemAt spellLangComponents 1);
    in if spellcheckerLanguage != null
      then ''
        --set HUNSPELL_DICTIONARIES "${hunspellDicts.${hunspellDict}}/share/hunspell" \
        --set LC_MESSAGES "${spellcheckerLanguage}"''
      else "");
in stdenv.mkDerivation rec {
  pname = "delta-desktop";
  
  version = "1.3.0";

  src = fetchurl {
    url = "https://download.delta.chat/desktop/v${version}/deltachat-desktop_${version}_amd64.deb";
    sha256 = "6cac4b88774eba04dc9647080b546ac74f23fee856a48a53727dac9b13a66e62";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook
  ];

  buildInputs = [
    alsaLib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gnome2.GConf
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libappindicator-gtk3
    libnotify
    libuuid
    nspr
    nss
    pango
    systemd
    xorg.libxcb
  ];

  runtimeDependencies = [
    systemd.lib
    libnotify
  ];

  unpackPhase = "dpkg-deb -x $src .";

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  # We need to run autoPatchelf manually with the "no-recurse" option, see
  # https://github.com/NixOS/nixpkgs/pull/78413 for the reasons.
  dontAutoPatchelf = true;

  installPhase = ''
    mkdir -p $out/lib
    mv usr/share $out/share
    mv opt/DeltaChat $out/lib/DeltaChat
    mkdir -p $out/bin
    ln -s $out/lib/DeltaChat/deltachat-desktop $out/bin/deltachat-desktop
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [ stdenv.cc.cc ] }"
      ${customLanguageWrapperArgs}
    )
    # Fix the desktop link
    substituteInPlace $out/share/applications/deltachat-desktop.desktop \
      --replace /opt/DeltaChat/deltachat-desktop $out/bin/deltachat-desktop
    autoPatchelf --no-recurse -- $out/lib/DeltaChat/
  '';

  # Tests if the application launches and waits for "Link your phone to Signal Desktop":
  passthru.tests.application-launch = nixosTests.deltachat-desktop;

  meta = {
    description = "Private, simple, and secure messenger";
    longDescription = ''
      DeltaChat Desktop is an Electron application
    '';
    homepage    = "https://delta.chat";
    changelog   = "https://github.com/deltachat/deltachat-desktop/releases/tag/v${version}";
    license     = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
    platforms   = [ "x86_64-linux" ];
  };
}
