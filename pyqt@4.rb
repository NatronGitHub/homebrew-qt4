class PyqtAT4 < Formula
  desc "Python bindings for Qt"
  homepage "https://www.riverbankcomputing.com/software/pyqt/intro"
  url "https://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-4.12.1/PyQt4_gpl_mac-4.12.1.tar.gz/download"
  sha256 "3224ab2c4d392891eb0abbc2bf076fef2ead3a5bb36ceae2383df4dda00ccce5"
  revision 1

  option "without-python@2", "Build without python 2 support"
  depends_on "python" => :optional

  if build.without?("python") && build.without?("python@2")
    odie "pyqt: --with-python must be specified when using --without-python@2"
  end

  depends_on "NatronGitHub/qt4/qt@4"
  depends_on "NatronGitHub/qt4/qt-webkit@2.3" => :recommended

  if build.with? "python"
    depends_on "sip" => "with-python"
  else
    depends_on "sip"
  end

  def install
    # On Mavericks we want to target libc++, this requires a non default qt makespec
    if ENV.compiler == :clang && MacOS.version >= :mavericks
      ENV.append "QMAKESPEC", "unsupported/macx-clang-libc++"
    end

    Language::Python.each_python(build) do |python, version|
      ENV.append_path "PYTHONPATH", "#{Formula["sip"].opt_lib}/python#{version}/site-packages"

      args = %W[
        --confirm-license
        --bindir=#{bin}
        --destdir=#{lib}/python#{version}/site-packages
        --sipdir=#{share}/sip
      ]

      # We need to run "configure.py" so that pyqtconfig.py is generated, which
      # is needed by QGIS, PyQWT (and many other PyQt interoperable
      # implementations such as the ROS GUI libs). This file is currently needed
      # for generating build files appropriate for the qmake spec that was used
      # to build Qt. The alternatives provided by configure-ng.py is not
      # sufficient to replace pyqtconfig.py yet (see
      # https://github.com/qgis/QGIS/pull/1508). Using configure.py is
      # deprecated and will be removed with SIP v5, so we do the actual compile
      # using the newer configure-ng.py as recommended. In order not to
      # interfere with the build using configure-ng.py, we run configure.py in a
      # temporary directory and only retain the pyqtconfig.py from that.

      require "tmpdir"
      dir = Dir.mktmpdir
      begin
        cp_r(Dir.glob("*"), dir)
        cd dir do
          system python, "configure.py", *args
          inreplace "pyqtconfig.py", "#{HOMEBREW_CELLAR}/#{Formula["cartr/qt4/qt@4"].name}/#{Formula["cartr/qt4/qt@4"].pkg_version}",
            Formula["cartr/qt4/qt@4"].opt_prefix
          (lib/"python#{version}/site-packages/PyQt4").install "pyqtconfig.py"
        end
      ensure
        remove_entry_secure dir
      end

      # On Mavericks we want to target libc++, this requires a non default qt makespec
      if ENV.compiler == :clang && MacOS.version >= :mavericks
        args << "--spec" << "unsupported/macx-clang-libc++"
      end

      args << "--no-stubs"

      system python, "configure-ng.py", *args
      system "make"
      system "make", "install"
      system "make", "clean" # for when building against multiple Pythons
    end
  end

  def caveats
    "Phonon support is broken."
  end

  test do
    Pathname("test.py").write <<~EOS
      from PyQt4 import QtNetwork
      QtNetwork.QNetworkAccessManager().networkAccessible()
    EOS

    Language::Python.each_python(build) do |python, _version|
      system python, "test.py"
    end
  end
  
  bottle do
    rebuild 1
    root_url "https://dl.bintray.com/devernay/bottles-qt4"
    sha256 "e44d7923a06753626ffc9bf6736b9641eb2b653bbd6ea34c841e1aaf2b9aadae" => :mojave
  end
end
