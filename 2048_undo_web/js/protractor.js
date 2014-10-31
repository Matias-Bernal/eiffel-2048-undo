  it('should check ng-bind-html', function() {
    expect(element(by.binding('menu')).getText()).toBe(
        'I am an HTMLstring with links! and other stuff');
  });