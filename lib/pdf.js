var page = require('webpage').create(),
    system = require('system'),
    address, output, size;
page.onAuthPrompt = function (type, url, realm, credentials) {
  credentials.username = system.args[5];
  credentials.password = system.args[6];
  return true;
}
address = system.args[1];

output = system.args[2];
page.paperSize = {
  format: system.args[3],
  orientation: system.args[4],
  margin: '0px'
};
page.open(address, function (status) {
  if (status !== 'success') {
      console.log('Unable to load the address!');
      phantom.exit(1);
  } else {
      window.setTimeout(function () {
          page.render(output);
          phantom.exit();
      }, 200);
  }
});
