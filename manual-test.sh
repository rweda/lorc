mkdir -p _tmp/bin/
cp lorc _tmp/bin/
cd _tmp/
echo "#!/bin/sh" > bin/util
echo "echo 'Utility run.'" >> bin/util
chmod +x bin/util
source bin/lorc
util # `Utility run.` should print to the console.
cd ../
#rm -rf _tmp
