class CutyCapt < Formula
  desc "Converts web pages to vector/bitmap images using WebKit"
  homepage "https://cutycapt.sourceforge.io/"
  url "https://deb.debian.org//debian/pool/main/c/cutycapt/cutycapt_0.0~svn6.orig.tar.gz"
  version "0.0.6"
  sha256 "cf85226a25731aff644f87a4e40b8878154667a6725a4dc0d648d7ec2d842264"
  revision 1

  depends_on "NatronGitHub/qt4/qt-webkit@2.3"
  depends_on "NatronGitHub/qt4/qt@4"

  def install
    system "qmake", "CONFIG-=app_bundle"
    system "make"
    bin.install "CutyCapt"
  end

  test do
    system "#{bin}/CutyCapt", "--url=http://brew.sh", "--out=brew.png"
    assert_predicate "brew.png", :exist?
  end
end
