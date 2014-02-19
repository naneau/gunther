(function() {
  var addAndRemoveTest, runTests;

  module('Lists');

  runTests = function(tests) {
    var next, runningTest;
    runningTest = 0;
    next = function() {
      if (runningTest === tests.length) {
        return start();
      }
      tests[runningTest]();
      runningTest++;
      return Gunther.Helper.animationFrame(next);
    };
    return next();
  };

  addAndRemoveTest = function() {
    var collection, elem, tests;
    expect(5);
    collection = new Backbone.Collection;
    elem = singleElement('div.list', collection, function() {
      return this.list('div.list', collection, new Gunther.Template(function(item) {
        return this.element("div.item." + (item.get('foo')));
      }));
    });
    equal(elem.children().length, 0, 'List should initialize when empty');
    tests = [];
    tests.push(function() {
      return collection.add({
        foo: 'bar',
        bar: 'baz1'
      });
    });
    tests.push(function() {
      return equal((elem.find('div.bar')).length, 1, 'List should add a single item');
    });
    tests.push(function() {
      collection.add({
        foo: 'bar',
        bar: 'baz2'
      });
      collection.add({
        foo: 'bar',
        bar: 'baz1'
      });
      collection.add({
        foo: 'bar',
        bar: 'baz2'
      });
      return collection.add({
        foo: 'bar',
        bar: 'baz1'
      });
    });
    tests.push(function() {
      return equal(elem.find('div.bar').length, 5, 'List should add multiple items');
    });
    tests.push(function() {
      return collection.remove(collection.first());
    });
    tests.push(function() {
      return equal(elem.find('div.bar').length, 4, 'list should remove a single item');
    });
    tests.push(function() {
      return collection.remove(collection.where({
        bar: 'baz1'
      }));
    });
    tests.push(function() {
      return equal(elem.find('div.bar').length, 2, 'list should remove multiple items');
    });
    return runTests(tests);
  };

  asyncTest('Adding And Removing Items', addAndRemoveTest);

  asyncTest('Adding And Removing Items, repeat', addAndRemoveTest);

  asyncTest('Lists, non empty', function() {
    var collection, elem, index, tests, _i;
    expect(5);
    collection = new Backbone.Collection;
    for (index = _i = 0; _i <= 9; index = ++_i) {
      collection.add({
        foo: 'bar',
        bar: 'baz1',
        index: index
      });
    }
    elem = singleElement('div.list', collection, function() {
      return this.list('div.list', collection, new Gunther.Template(function(item) {
        return this.element("div.item." + (item.get('foo')) + ".index-" + (item.get('index')));
      }));
    });
    tests = [];
    tests.push(function() {
      return equal(elem.children().length, 10, 'List should initialize with right set of elements');
    });
    tests.push(function() {
      return collection.add({
        foo: 'foo',
        bar: 'baz2',
        index: 10
      });
    });
    tests.push(function() {
      return equal(elem.find('div.item.foo').length, 1, 'List should add a single item');
    });
    tests.push(function() {
      collection.add({
        foo: 'foo',
        bar: 'baz2',
        index: 11
      });
      collection.add({
        foo: 'foo',
        bar: 'baz2',
        index: 12
      });
      return collection.add({
        foo: 'foo',
        bar: 'baz2',
        index: 13
      });
    });
    tests.push(function() {
      return equal(elem.find('div.item.foo').length, 4, 'List should add multiple items');
    });
    tests.push(function() {
      return collection.remove(collection.last());
    });
    tests.push(function() {
      return equal(elem.find('div.item.foo').length, 3, 'list should remove a single item');
    });
    tests.push(function() {
      return collection.remove(collection.where({
        foo: 'bar'
      }));
    });
    tests.push(function() {
      return equal(elem.find('div.item.foo').length, 3, 'list should remove multiple items');
    });
    return runTests(tests);
  });

  asyncTest('Lists, large item counts', function() {
    var add, check, collection, elem, maxNumRuns, multiplier;
    expect(1);
    collection = new Backbone.Collection;
    elem = singleElement('div.list', collection, function() {
      return this.list('div.list', collection, new Gunther.Template(function(item) {
        return this.element("div.item." + (item.get('foo')) + ".index-" + (item.get('index')), function() {
          return this.t(item.get('index'));
        });
      }));
    });
    maxNumRuns = 100;
    multiplier = 10;
    add = function(runCount) {
      var x, _i, _ref;
      for (x = _i = 0, _ref = multiplier - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        collection.add({
          foo: 'bar',
          index: runCount + '.' + x
        });
      }
      if (runCount === (maxNumRuns - 1)) {
        return check(maxNumRuns * multiplier);
      }
      return add(runCount + 1);
    };
    check = function(count) {
      return Gunther.Helper.animationFrame(function() {
        equal(elem.find('div.item.bar').length, count, "List should have " + count + " items in the end");
        return start();
      });
    };
    return add(0);
  });

}).call(this);
