class ShibokenAT12 < Formula
  desc "C++ GeneratorRunner plugin for CPython extensions"
  homepage "https://wiki.qt.io/PySide"
  url "https://github.com/pyside/Shiboken/archive/1.2.4.tar.gz"
  mirror "https://distfiles.macports.org/py-shiboken/Shiboken-1.2.4.tar.gz"
  sha256 "1536f73a3353296d97a25e24f9554edf3e6a48126886f8d21282c3645ecb96a4"

  head "https://github.com/PySide/Shiboken.git"

  bottle do
    root_url "https://dl.bintray.com/devernay/bottles-qt4"
    sha256 cellar: :any, mojave: "9ee4301c0fb346c05db64e1b83575dd5f545f5e6a5995d93c24bac1128209914"
  end

  option "without-python@2", "Build without python 2 support"

  depends_on "cmake" => :build
  depends_on "NatronGitHub/qt4/qt@4"

  # don't use depends_on :python because then bottles install Homebrew's python
  depends_on "python@2" => :recommended if MacOS.version <= :snow_leopard
  depends_on "python" => :optional

  def install
    # As of 1.1.1 the install fails unless you do an out of tree build and put
    # the source dir last in the args.
    Language::Python.each_python(build) do |python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args
        # Building the tests also runs them.
        args << "-DBUILD_TESTS=ON"
        if python == "python3" && Formula["python"].installed?
          python_framework = Formula["python"].opt_prefix/"Frameworks/Python.framework/Versions/#{version}"
          args << "-DPYTHON3_INCLUDE_DIR:PATH=#{python_framework}/Headers"
          args << "-DPYTHON3_LIBRARY:FILEPATH=#{python_framework}/lib/libpython#{version}.dylib"
        end
        args << "-DUSE_PYTHON3:BOOL=ON" if python == "python3"
        args << ".."
        system "cmake", *args
        system "make", "install"
      end
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import shiboken"
    end
  end
end
