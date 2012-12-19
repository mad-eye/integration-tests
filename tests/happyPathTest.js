var casper = require("casper").create();
casper.echo("casper passed args", casper.cli.args);
