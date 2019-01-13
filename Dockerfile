FROM monachus/hugo


CMD hugo server -b ${HUGO_BASE_URL} --bind=0.0.0.0 --appendPort=false --disableLiveReload