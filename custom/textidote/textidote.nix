# textidote.nix
#
# Packages textidote.
#
# You can build this file with the following command:
#
#   nix-build textidote.nix
#
# This will create the symlink result in the current directory.  The
# runnable shell script is result/bin/textidote.

# License at the end of file

let
  # Import nixpkgs to be able to supply reasonable default values for
  # the anonymous function this file defines.
  pkgs = import <nixpkgs> {};
in
# These arguments define the resources (packages and native Nix tools)
# that will be used by the package.
# I want this file to be buildable directly using the command
# nix-build textidote.nix, so I have to supply reasonable default values
# to these arguments.  The default values naturally come from the
# corresponding attributes of Nixpkgs, visible here under the binding
# pkgs.
{ stdenv ? pkgs.stdenv
, lib ? pkgs.lib
, fetchurl ? pkgs.fetchurl
, makeWrapper ? pkgs.makeWrapper
, jre ? pkgs.jre
}:

# I'll use the default builder, because I don't need any particular
# features.
stdenv.mkDerivation rec {
  pname = "textidote-bin";
  version = "0.8.3";
  name = "${pname}-${version}";

  # Simply fetch the JAR file of textidote.
  src = fetchurl {
    url = "https://github.com/sylvainhalle/textidote/releases/download/v${version}/textidote.jar";
    hash = "sha256-BIYswDrVqNEB+J9TwB0Fop+AC8qvPo53KGU7iupC7tk=";
  };

  unpackPhase = "true";
  buildPhase = "true";

  # I need makeWrapper in my build environment to generate the wrapper
  # shell script.  This shell script will call the Java executable on
  # the JAR file of textidote and will set the appropriate environment
  # variables.
  nativeBuildInputs = [ makeWrapper ];
  # nativeBuildInputs = [ jre makeWrapper ];

  # The only meaningful phase of this build.  I create the
  # subdirectory share/java/ in the output directory, because this is
  # where JAR files are typically stored.  I also create the
  # subdirectory bin/ to store the executable shell script.  I then
  # copy the downloaded JAR file to $out/share/java/.  Once this is
  # done, I create the wrapper shell script using makeWrapper.  This
  # script wraps the Java executable (${jre}/bin/java) in the output
  # shell script file $out/bin/textidote.  The script adds the argument
  # -jar … to the Java executable, thus pointing it to the actual
  # textidote JAR file.
  installPhase = ''
    mkdir -pv $out/share/java $out/bin
    cp ${src} $out/share/java/${name}.jar

    makeWrapper ${jre}/bin/java $out/bin/textidote \
      --add-flags "-jar $out/share/java/${name}.jar"
  '';

  meta = with lib; {
    description = "A grammar checker that integrates LanguageTool with LaTeX documents";
    homepage = "https://github.com/sylvainhalle/textidote";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
  };
}
