
tagGen - cable tag generator
============================

Copyright (C) 2020 Kenneth Aaron.

flyingrhino AT orcon DOT net DOT nz

Freedom makes a better world: released under GNU GPLv3.

https://www.gnu.org/licenses/gpl-3.0.en.html

This software can be used by anyone at no cost, however,
if you like using my software and can support - please
donate money to a children's hospital of your choice.

This program is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation:
GNU GPLv3. You must include this entire text with your
distribution.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See the GNU General Public License for more details.


Usage
=====

Copy to any directory, make executable and run.
You will be using the value from the `Cable tag` field,
the other fields are for understanding the inner workings
of the script and troubleshooting errors.
Requires bash and bc, you'll probably already have both
installed on your distro.

Example:
```
./tagGen.sh

Epoch time    Base-28 conversion           Cable tag
----------    ------------------           ---------
1603573470 ,  03 09 04 25 02 09 02  ====>  394 W29
1603573501 ,  03 09 04 25 02 10 05  ====>  394 W2A
1603573532 ,  03 09 04 25 02 11 08  ====>  394 W2C
```

tagGen generates unique labels which are representative of
the current time, and uses a selection of letters that are
not easily confused with others - for example we skip I, O
and several others.
In essence this is conversion of epoch time to a
(currently and for a long time to come) 6 digit code,
comprising of letters and numbers (base-28).
The reason you receive one output every half minute is
because I want the tag to represent the time of generation,
as well as be as short as possible to be usable. No one will
tag a cable every second, so we can drop the seventh digit.

Typical use case - tag cables in a data center, where the
tag is guaranteed to be unique, represents the time it was
made, and short enough to be usable.
Various software can handle these tags such as the excellent NetBox.

Normally what I do when tagging cables is run tagGen nonstop:
`./tagGen.sh` and simply use the latest output when it's time to
tag the next cable.

A few more options exist via command line arguments as seen in tagGen help:

```
./tagGen.sh -h

./tagGen.sh With no arguments - generates tags nonstop. Press Ctrl-c to stop.
-h        Display this help message and exit.
-s        Single mode - generate one tag and exit.
-n        Nonstop mode - generate tags nonstop - press ctrl-c to stop.
-d <TAG>  Decode <TAG> back to epoch. <TAG> must be supplied with no spaces!
```

Note - when decoding tag back to epoch - you will see the base
time of the 6 character tag. Remember - we drop the seventh digit
at tag creation time.
Therefore the time conversion will be lower that the real
time by up to 28 seconds because we assume the seventh digit
to be zero at the -d calculation time.

That's it - simple and works.
Enjoy...

