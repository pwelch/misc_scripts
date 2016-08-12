.PHONY: clean setup package

clean:
	-rm package.zip
	-rm -rf requests*

setup:
	@pip install -r requirements.txt -t .

package: setup
	@zip package.zip -r . -x "*.git*"

