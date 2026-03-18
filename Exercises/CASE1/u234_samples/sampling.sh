python -m sandy.sampling  U234.dat --samples 10 --acer --temperatures 293.15
outdir=ACEFILES
mkdir -p $outdir
mv -v 92234_* $outdir