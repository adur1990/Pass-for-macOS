CASK_TEMPLATE="
cask 'passformacos' do\n
\tdepends_on formula: 'pass'\n
\tdepends_on macos: '>= :mojave'\n
\n
\tversion '$VERSION'\n
\tsha256 '$HASH'\n
\n
\turl \"https://github.com/adur1990/Pass-for-macOS/releases/download/#{version}/Pass.for.macOS.app.zip\"\n
\tname 'Pass for macOS'\n
\thomepage 'https://github.com/adur1990/Pass-for-macOS'\n
\n
\tapp 'Pass for macOS.app'\n
end"

