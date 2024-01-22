###############################################################################
#  1 alphafold/scripts/download_alphafold_params.sh
###############################################################################
mkdir --parents "/root/pdb/params"
tar --extract --verbose --file=/root/pdb/alphafold_params_2022-03-02.tar \
  --directory=/root/pdb/params --preserve-permissions
