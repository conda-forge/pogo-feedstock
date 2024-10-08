# Update the version in pom files (remove SNAPSHOT)
mvn versions:set versions:update-child-modules -DnewVersion="${PKG_VERSION}" -DprocessAllModule -DgenerateBackupPoms=false -Prelease
# Skip the tests because they require to have a tango database running
mvn install -DskipTests

# Generate third party license report
mvn license:aggregate-third-party-report
cp target/site/aggregate-third-party-report.html .

mkdir -p ${PREFIX}/share/java ${PREFIX}/bin
install -m 0644 org.tango.pogo.gui/target/Pogo-${PKG_VERSION}.jar ${PREFIX}/share/java
ln -s Pogo-${PKG_VERSION}.jar ${PREFIX}/share/java/Pogo.jar

# Install pogo preferences
export POGO_PREFERENCES=${PREFIX}/share/pogo/preferences
mkdir -p ${POGO_PREFERENCES}
install -m 0644 ${RECIPE_DIR}/preferences/* ${POGO_PREFERENCES}/
sed -i "s?^org.tango.pogo.makefile_home:.*?org.tango.pogo.makefile_home: ${POGO_PREFERENCES}?g"  ${POGO_PREFERENCES}/Pogo.site_properties

# Create pogo script
cat << EOF > $PREFIX/bin/pogo
#!/bin/sh

POGO_PREFERENCES=${POGO_PREFERENCES}
POGO_CLASS=${PREFIX}/share/java/Pogo.jar

export CLASSPATH=\$POGO_PREFERENCES:\$POGO_CLASS

java org.tango.pogo.gui.Pogo "\$@"
EOF
chmod a+x $PREFIX/bin/pogo
