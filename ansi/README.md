# Zen

- comptime support for static coloring
- support for dynamic (non-comptime) coloring too
- API for changing state (for multiple writes with the same styling)
- API for str decoration (for single write with isolated styling)
- API for chaining decoration
- API namespacing
- API inspiration: https://www.npmjs.com/package/chalk
- API iterate over colors (color indexes)
- API get some aliases from chalk (grey and gray, for example)
- freestanding if possible
- zero allocations if possible (gimme your buffer)
- minimize writes
- flexible, consistent and well documented api
- color mode as input (tell us your environment, we wont waste effort and time trying to discover what you already know)
- tests
- docs
- thread safety!?
