/*
 * MessagePack for Ruby
 *
 * Copyright (C) 2008-2015 Sadayuki Furuhashi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include "unpacker_ext_registry.h"

static ID s_call;
static ID s_dup;

void msgpack_unpacker_ext_registry_static_init(void)
{
    s_call = rb_intern("call");
    s_dup = rb_intern("dup");
}


void msgpack_unpacker_ext_registry_static_destroy(void)
{ }

void msgpack_unpacker_ext_registry_mark(msgpack_unpacker_ext_registry_t* ukrg)
{
    if (ukrg) {
        for(int i=0; i < 256; i++) {
            if (ukrg->array[i] != Qnil) {
                rb_gc_mark(ukrg->array[i]);
            }
        }
    }
}

msgpack_unpacker_ext_registry_t* msgpack_unpacker_ext_registry_cow(msgpack_unpacker_ext_registry_t* src)
{
    msgpack_unpacker_ext_registry_t* dst;
    if (src) {
        if (src->borrow_count) {
            dst = ALLOC(msgpack_unpacker_ext_registry_t);
            dst->borrow_count = 0;
            MEMCPY(dst->array, src->array, VALUE, 256);
            msgpack_unpacker_ext_registry_release(src);
            return dst;
        } else {
            return src;
        }
    } else {
        dst = ALLOC(msgpack_unpacker_ext_registry_t);
        dst->borrow_count = 0;
        for(int i=0; i < 256; i++) {
            dst->array[i] = Qnil;
        }
        return dst;
    }
}

void msgpack_unpacker_ext_registry_release(msgpack_unpacker_ext_registry_t* ukrg)
{
    if (ukrg) {
        if (ukrg->borrow_count) {
            ukrg->borrow_count--;
        } else {
            xfree(ukrg);
        }
    }
}

void msgpack_unpacker_ext_registry_put(msgpack_unpacker_ext_registry_t** ukrg,
        VALUE ext_module, int ext_type, int flags, VALUE proc, VALUE arg)
{
    msgpack_unpacker_ext_registry_t* ext_registry = msgpack_unpacker_ext_registry_cow(*ukrg);

    ext_registry->array[ext_type + 128] = rb_ary_new3(4, ext_module, proc, arg, INT2FIX(flags));
    *ukrg = ext_registry;
}
