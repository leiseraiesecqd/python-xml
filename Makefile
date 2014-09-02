# Manage project
#
# You can run unittests using ...
# - python -m test.testemployees -v
# - python -m unittest discover -v

COMMA:= ,
EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)

COVER_DIR = target/cover
# srcs used by pychecker
SRCS=employees/main.py employees/employees.py test/testemployees.py
SRCS_LIST=$(subst $(SPACE),$(COMMA),$(SRCS))

.PROXY: all

all: check cover run test doc dist

help:
	@echo "Default targets: all"
	@echo "  all: check cover run test doc dist"
	@echo "  clean: delete all generated files"

check:
	# Check with PyChecker
	pychecker --only $(SRCS)
	# Check with Pep8
	pep8 --verbose $(SRCS)
	# Check distutils
	python setup.py check

cover:
	# Run main module
	python-coverage run --source=employees --include=main.py,employees.py -m employees.main
	# Run main module with verbose and test data
	python-coverage run -a --source=employees --include=main.py,employees.py -m employees.main -v data/test.xml
	# Run unit tests (append results)
	python-coverage run -a --source=employees --include=main.py,employees.py -m test.testemployees
	# Annotate file to see what has been tested
	python-coverage annotate employees/employees.py employees/main.py
	# Generate unit test coverage report
	python-coverage report

run:
	# Run main
	python -m employees.main -v data/test.xml

test: force_make
	# Run unit tests
	# python -m unittest discover -v
	# List nodetests plugins using nosetests --plugins -vv
	# Make directory for HTML test results to be included in documentation
	mkdir -p target/test
	# Search test directory
	nosetests --config=test/nosetests.cfg --verbose --where $(PWD) test/test*.py
	# Compare with
	# python -m test.testemployees -v
	# Test documentation (run coverage first)
	# (cd docs; make doctest; make linkcheck)

doc: force_make
	# Creating coverage HTML report to be included in final documentation
	$(RM) -rf $(COVER_DIR)
	python-coverage html -d $(COVER_DIR)
	# Create Sphinx documentation
	(cd docs; make singlehtml)

dist: force_make
	# Create source package and build distribution
	python setup.py clean
	python setup.py sdist --dist-dir=target/dist 
	python setup.py build --build-base=target/build

clean: force_make 
	# Cleaning workspace
	python-coverage erase
	# Clean build distribution
	python setup.py clean
	# Clean generated documents
	(cd docs; make clean)
	$(RM) -v *,cover
	$(RM) -v MANIFEST
	$(RM) -v .noseids
	$(RM) -v *.pyc *.pyo
	$(RM) -v employees/*.pyc employees/*.pyo employees/*.py,cover
	$(RM) -v test/*.pyc test/*.pyo test/*.py,cover
	$(RM) -rf target

force_make:
	true

#EOF
