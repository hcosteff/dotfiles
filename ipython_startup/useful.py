 #!/usr/bin/python
import sys,os
from collections import defaultdict
import dateutil
import dateutil.parser
import glob
import re
import subprocess

import easypy
import easypy.bunch
import easypy.collections
listc = easypy.collections.ListCollection
Bunch = easypy.bunch.Bunch

dateparse = dateutil.parser.parse

MAGNITUDE = lambda n:         ((n) * 1000)
MICRO_TO_NANO = lambda n:     MAGNITUDE(n)
MILLI_TO_MICRO = lambda n:    MAGNITUDE(n)
SEC_TO_MILLI = lambda n:      MAGNITUDE(n)
MILLI_TO_NANO = lambda n:     MICRO_TO_NANO(MILLI_TO_MICRO(n))
SEC_TO_MICRO = lambda n:      MILLI_TO_MICRO(SEC_TO_MILLI(n))
SEC_TO_NANO = lambda n:       MICRO_TO_NANO(SEC_TO_MICRO(n))
MINITUDE = lambda n:          ((n) / 1000)
NANO_TO_MICRO = lambda n:     MINITUDE(n)
MICRO_TO_MILLI = lambda n:    MINITUDE(n)
MILLI_TO_SEC = lambda n:      MINITUDE(n)
NANO_TO_MILLI = lambda n:     MICRO_TO_MILLI(NANO_TO_MICRO(n))
MICRO_TO_SEC = lambda n:      MILLI_TO_SEC(MICRO_TO_MILLI(n))
NANO_TO_SEC = lambda n:       MICRO_TO_SEC(NANO_TO_MICRO(n))

kb = 1024
mb = kb * 1024
gb = mb * 1024
tb = gb * 1024
pb = tb * 1024

def expressive_notation(x):
    tb_component = int(x / tb);
    gb_component = int((x % tb) / gb);
    mb_component = int((x % gb) / mb);
    kb_component = int((x % mb) / kb);
    byte_component = (x % kb);
    res = []
    if tb_component or gb_component or mb_component or kb_component:
        if tb_component:
            res.append(f"{tb_component}*tb")
        if gb_component:
            res.append(f"{gb_component}*gb")
        if mb_component:
            res.append(f"{mb_component}*mb")
        if kb_component:
            res.append(f"{kb_component}*kb")
        if byte_component:
            res.append(f"{byte_component}")
        return " + ".join(res)
    else:
        return ""

class MyPatchedInt(int):
    expressive_notation=expressive_notation


kilo = 1000
mega = kilo * 1000
giga = mega * 1000
tera = giga * 1000
peta = tera * 1000


class roundhelpers:
    up = lambda x, alignment: (int((x+alignment-1)/alignment)*alignment)
    down = lambda x, alignment: (int(x/alignment)*alignment)
IO_ALIGN_UP = lambda x: round.up(x, 512)
IO_ALIGN_DOWN = lambda x: round.down(x, 512)

def string_to_lines_without_newline(s):
    return [x for x in s.split("\n") if x]


def openlines(filename):
    return string_to_lines_without_newline(open(filename).read())


#<<<<<<<< uint*_t types
class classproperty(property):
    def __get__(self, cls, owner):
        return classmethod(self.fget).__get__(None, owner)()

def _build_delegate(name, attr, cls, _type):
    def f(*args, **kwargs):
        args = tuple(a if not isinstance(a, cls) else a._int for a in args)
        ret = attr(*args, **kwargs)
        if not isinstance(ret, _type) or name == '__hash__':
            return ret
        return cls(ret)
    return f


def delegated_special_methods(_type, n_bits):
    def decorator(cls):
        for name, value in vars(_type).items():
            if (name[:2], name[-2:]) != ('__', '__') or not callable(value):
                continue
            if hasattr(cls, name) and not name in ('__repr__', '__hash__'):
                continue
            setattr(cls, name, _build_delegate(name, value, cls, _type))
            setattr(cls, "N_BITS", n_bits);
        return cls
    return decorator

class LimitedInt(object):
    @classproperty
    def max(cls):
        return cls(-1)
    @classproperty
    def min(cls):
        return cls(0)
    
    def __init__(self, num=0, base=None):
        if base is None:
            self._int = int(num) % 2**self.N_BITS
        else:
            self._int = int(num, base) % 2**self.N_BITS
    def __coerce__(self, ignored):
        return None
    def __str__(self):
        return "<%s instance at 0x%x, value=%d>" % (self.__class__.__name__, id(self), self._int)

#<<<<<<<< uint* types
@delegated_special_methods(int, 8)
class uint8(LimitedInt):
    pass

@delegated_special_methods(int, 16)
class uint16(LimitedInt):
    pass

@delegated_special_methods(int, 32)
class uint32(LimitedInt):
    pass

@delegated_special_methods(int, 64)
class uint64(LimitedInt):
    pass

@delegated_special_methods(int, 28)
class ContentIndex(LimitedInt):
    pass



class hexint(int):
    def __repr__(self):
        return "0x{:x}".format(self)

def extract_eqs(s, replace_periods = True):
    def extract_single(s):
        def parse_value(v):
            if bool(re.match("^0x[0-9a-f]+$",v)):
                return hexint(v,16)
            if bool(re.match("^[0-9]+$",v)):
                return int(v)                
            
            if v[0] in ['"', '\'']:
                assert v[-1] in ['"', '\''], "invalid eq"
                return v[1:-1]
            return v
            
        m = re.findall("([a-zA-Z0-9_.]+) ?= ?([0-9'\"A-Za-z_.]+)", s)
        return Bunch({k.replace(".", "_") if replace_periods else k: parse_value(v)  for k,v in m})

    if s.count('\n') == 0 or (s.count('\n') == 1 and s[-1] == '\n'):
        return extract_single(s)

    res = []
    for l in string_to_lines_without_newline(s):
        res.append(extract_single(l))
    return res


def run_shell(*cmd):
    print(cmd)
    return subprocess.run(cmd, 
                         stdout=subprocess.PIPE, 
                         stderr=subprocess.PIPE, 
                         universal_newlines=True,
                         shell=True)
