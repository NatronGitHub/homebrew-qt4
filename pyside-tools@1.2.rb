class PysideToolsAT12 < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide"
  url "https://github.com/PySide/Tools/archive/0.2.15.tar.gz"
  sha256 "8a7fe786b19c5b2b4380aff0a9590b3129fad4a0f6f3df1f39593d79b01a9f74"
  revision 1

  head "https://github.com/PySide/Tools.git"

  bottle do
    root_url "https://dl.bintray.com/devernay/bottles-qt4"
    rebuild 3
    sha256 cellar: :any, big_sur: "a000cc61dca07e10438f7c91ad731b9ae8d3883b922eb4f04d59df2f03ac12c6"
    sha256 mojave: "6eda5d9dc88477e751efb4d0985074e1163bfe42e48805f1f4a689b01fb230cf"
  end

  depends_on "cmake" => :build
  depends_on "NatronGitHub/qt4/pyside@1.2"

  def install
    system "cmake", ".", "-DSITE_PACKAGE=lib/python2.7/site-packages", *std_cmake_args
    system "make", "install"
  end
end
