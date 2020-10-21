
taggen - cable tag generator
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
Requires bash and bc, you'll probably already have both
installed on your distro.

taggen generates unique labels which are representative of
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

That's it - simple and works.
Enjoy...

