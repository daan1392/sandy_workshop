#!/usr/bin/env bash
set -e

echo "🔧 Post-create setup starting..."

# Create data directory
mkdir -p $HOME/data

# Download OpenMC cross sections (optional)
echo "📦 Downloading ENDF/B-VIII.0 HDF5 cross sections..."
wget -q https://anl.box.com/shared/static/fmcr8zoox1t6um0rwb2iw1nz72xue8ol.xz -O $HOME/data/endfb80_hdf5.xz || echo "⚠ Failed to download cross sections, skipping"

# Extract only if the file exists
if [ -f "$HOME/data/endfb80_hdf5.xz" ]; then
    echo "📦 Extracting cross sections..."
    tar -xf $HOME/data/endfb80_hdf5.xz -C $HOME/data/
    rm $HOME/data/endfb80_hdf5.xz
fi

# Set environment variable for OpenMC
echo "export OPENMC_CROSS_SECTIONS=$HOME/data/endfb80_hdf5/cross_sections.xml" >> $HOME/.bashrc

echo "🔍 Checking installation..."
openmc --version || echo "⚠ OpenMC not found!"
njoy --version || echo "⚠ NJOY not found!"

echo "🎉 SANDY Environment Ready!"
