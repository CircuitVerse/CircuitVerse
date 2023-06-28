package org.msgpack.jruby;


import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyClass;
import org.jruby.RubyObject;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.RubyIO;
import org.jruby.RubyInteger;
import org.jruby.RubyFixnum;
import org.jruby.RubyString;
import org.jruby.RubySymbol;
import org.jruby.RubyProc;
import org.jruby.RubyMethod;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyClass;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.util.ByteList;

import static org.jruby.runtime.Visibility.PRIVATE;

@JRubyClass(name="MessagePack::Factory")
public class Factory extends RubyObject {
  private static final long serialVersionUID = 8441284623445322492L;
  private final Ruby runtime;
  private ExtensionRegistry extensionRegistry;
  private boolean hasSymbolExtType;
  private boolean hasBigIntExtType;

  public Factory(Ruby runtime, RubyClass type) {
    super(runtime, type);
    this.runtime = runtime;
    this.extensionRegistry = new ExtensionRegistry();
    this.hasSymbolExtType = false;
    this.hasBigIntExtType = false;
  }

  static class FactoryAllocator implements ObjectAllocator {
    public IRubyObject allocate(Ruby runtime, RubyClass type) {
      return new Factory(runtime, type);
    }
  }

  public ExtensionRegistry extensionRegistry() {
    return extensionRegistry.dup();
  }

  @JRubyMethod(name = "initialize")
  public IRubyObject initialize(ThreadContext ctx) {
    return this;
  }

  @JRubyMethod(name = "dup")
  public IRubyObject dup() {
    Factory clone = (Factory)super.dup();
    clone.extensionRegistry = extensionRegistry();
    clone.hasSymbolExtType = hasSymbolExtType;
    return clone;
  }

  @JRubyMethod(name = "packer", optional = 2)
  public Packer packer(ThreadContext ctx, IRubyObject[] args) {
    return Packer.newPacker(ctx, extensionRegistry(), hasSymbolExtType, hasBigIntExtType, args);
  }

  @JRubyMethod(name = "unpacker", optional = 2)
  public Unpacker unpacker(ThreadContext ctx, IRubyObject[] args) {
    return Unpacker.newUnpacker(ctx, extensionRegistry(), args);
  }

  @JRubyMethod(name = "registered_types_internal", visibility = PRIVATE)
  public IRubyObject registeredTypesInternal(ThreadContext ctx) {
    return RubyArray.newArray(ctx.runtime, new IRubyObject[] {
      extensionRegistry.toInternalPackerRegistry(ctx),
      extensionRegistry.toInternalUnpackerRegistry(ctx)
    });
  }

  @JRubyMethod(name = "register_type", required = 2, optional = 1)
  public IRubyObject registerType(ThreadContext ctx, IRubyObject[] args) {
    Ruby runtime = ctx.runtime;
    IRubyObject type = args[0];
    IRubyObject mod = args[1];

    IRubyObject packerArg;
    IRubyObject unpackerArg;

    RubyHash options = null;

    if (isFrozen()) {
        throw runtime.newRuntimeError("can't modify frozen Factory");
    }

    if (args.length == 2) {
      packerArg = runtime.newSymbol("to_msgpack_ext");
      unpackerArg = runtime.newSymbol("from_msgpack_ext");
    } else if (args.length == 3) {
      if (args[args.length - 1] instanceof RubyHash) {
        options = (RubyHash) args[args.length - 1];
        packerArg = options.fastARef(runtime.newSymbol("packer"));
        unpackerArg = options.fastARef(runtime.newSymbol("unpacker"));
        IRubyObject optimizedSymbolsParsingArg = options.fastARef(runtime.newSymbol("optimized_symbols_parsing"));
        if (optimizedSymbolsParsingArg != null && optimizedSymbolsParsingArg.isTrue()) {
          throw runtime.newArgumentError("JRuby implementation does not support the optimized_symbols_parsing option");
        }
      } else {
        throw runtime.newArgumentError(String.format("expected Hash but found %s.", args[args.length - 1].getType().getName()));
      }
    } else {
      throw runtime.newArgumentError(String.format("wrong number of arguments (%d for 2..3)", 2 + args.length));
    }

    long typeId = ((RubyFixnum) type).getLongValue();
    if (typeId < -128 || typeId > 127) {
      throw runtime.newRangeError(String.format("integer %d too big to convert to `signed char'", typeId));
    }

    if (!(mod instanceof RubyModule)) {
      throw runtime.newArgumentError(String.format("expected Module/Class but found %s.", mod.getType().getName()));
    }
    RubyModule extModule = (RubyModule) mod;

    IRubyObject packerProc = runtime.getNil();
    IRubyObject unpackerProc = runtime.getNil();
    if (packerArg != null) {
      packerProc = packerArg.callMethod(ctx, "to_proc");
    }
    if (unpackerArg != null) {
      if (unpackerArg instanceof RubyString || unpackerArg instanceof RubySymbol) {
        unpackerProc = extModule.method(unpackerArg.callMethod(ctx, "to_sym"));
      } else if (unpackerArg instanceof RubyProc || unpackerArg instanceof RubyMethod) {
        unpackerProc = unpackerArg;
      } else {
        unpackerProc = unpackerArg.callMethod(ctx, "method", runtime.newSymbol("call"));
      }
    }

    boolean recursive = false;
    if (options != null) {
      IRubyObject recursiveExtensionArg = options.fastARef(runtime.newSymbol("recursive"));
      if (recursiveExtensionArg != null && recursiveExtensionArg.isTrue()) {
        recursive = true;
      }
    }

    extensionRegistry.put(extModule, (int) typeId, recursive, packerProc, packerArg, unpackerProc, unpackerArg);

    if (extModule == runtime.getSymbol()) {
      hasSymbolExtType = true;
    }

    if (options != null) {
      IRubyObject oversizedIntegerExtensionArg = options.fastARef(runtime.newSymbol("oversized_integer_extension"));
      if (oversizedIntegerExtensionArg != null && oversizedIntegerExtensionArg.isTrue()) {
        if (extModule == runtime.getModule("Integer")) {
          hasBigIntExtType = true;
        } else {
          throw runtime.newArgumentError("oversized_integer_extension: true is only for Integer class");
        }
      }
    }

    return runtime.getNil();
  }
}
