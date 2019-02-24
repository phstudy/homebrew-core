class GnuTar < Formula
  desc "GNU version of the tar archiving utility"
  homepage "https://www.gnu.org/software/tar/"
  url "https://ftp.gnu.org/gnu/tar/tar-1.32.tar.gz"
  mirror "https://ftpmirror.gnu.org/tar/tar-1.32.tar.gz"
  sha256 "b59549594d91d84ee00c99cf2541a3330fed3a42c440503326dab767f2fbb96c"

  bottle do
    cellar :any_skip_relocation
    rebuild 2
    sha256 "b9e065ee7a535f28e0f40b8093d2fbd42fe7fb9cdb11978409c0362118b4c8ef" => :mojave
    sha256 "18a704a06a6b333653f4a25783a7adbf7932cef0bad8980ba2eefd7697c8f64a" => :high_sierra
    sha256 "8937c1698aeceec85eb5442e469b49ac706c45e8c8aa466ee2503874e5c8dcad" => :sierra
  end

  head do
    url "https://git.savannah.gnu.org/git/tar.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gettext" => :build
  end

  def install
    # Work around unremovable, nested dirs bug that affects lots of
    # GNU projects. See:
    # https://github.com/Homebrew/homebrew/issues/45273
    # https://github.com/Homebrew/homebrew/issues/44993
    # This is thought to be an el_capitan bug:
    # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
    ENV["gl_cv_func_getcwd_abort_bug"] = "no" if MacOS.version == :el_capitan

    args = %W[
      --prefix=#{prefix}
      --mandir=#{man}
      --program-prefix=g
    ]

    system "./bootstrap" if build.head?
    system "./configure", *args
    system "make", "install"

    # Symlink the executable into libexec/gnubin as "tar"
    (libexec/"gnubin").install_symlink bin/"gtar" =>"tar"
    (libexec/"gnuman/man1").install_symlink man1/"gtar.1" => "tar.1"

    libexec.install_symlink "gnuman" => "man"
  end

  def caveats; <<~EOS
    GNU "tar" has been installed as "gtar".
    If you need to use it as "tar", you can add a "gnubin" directory
    to your PATH from your bashrc like:

        PATH="#{opt_libexec}/gnubin:$PATH"
  EOS
  end

  test do
    (testpath/"test").write("test")
    system bin/"gtar", "-czvf", "test.tar.gz", "test"
    assert_match /test/, shell_output("#{bin}/gtar -xOzf test.tar.gz")

    assert_match /test/, shell_output("#{opt_libexec}/gnubin/tar -xOzf test.tar.gz")
  end
end
