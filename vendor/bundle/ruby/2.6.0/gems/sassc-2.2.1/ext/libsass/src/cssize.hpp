#ifndef SASS_CSSIZE_H
#define SASS_CSSIZE_H

#include "ast.hpp"
#include "context.hpp"
#include "operation.hpp"
#include "environment.hpp"

namespace Sass {

  struct Backtrace;

  class Cssize : public Operation_CRTP<Statement*, Cssize> {

    Context&                    ctx;
    Backtraces&                 traces;
    BlockStack      block_stack;
    std::vector<Statement*>  p_stack;

  public:
    Cssize(Context&);
    ~Cssize() { }

    Selector_List* selector();

    Block* operator()(Block*);
    Statement* operator()(Ruleset*);
    // Statement* operator()(Bubble*);
    Statement* operator()(Media_Block*);
    Statement* operator()(Supports_Block*);
    Statement* operator()(At_Root_Block*);
    Statement* operator()(Directive*);
    Statement* operator()(Keyframe_Rule*);
    Statement* operator()(Trace*);
    Statement* operator()(Declaration*);
    // Statement* operator()(Assignment*);
    // Statement* operator()(Import*);
    // Statement* operator()(Import_Stub*);
    // Statement* operator()(Warning*);
    // Statement* operator()(Error*);
    // Statement* operator()(Comment*);
    // Statement* operator()(If*);
    // Statement* operator()(For*);
    // Statement* operator()(Each*);
    // Statement* operator()(While*);
    // Statement* operator()(Return*);
    // Statement* operator()(Extension*);
    // Statement* operator()(Definition*);
    // Statement* operator()(Mixin_Call*);
    // Statement* operator()(Content*);
    Statement* operator()(Null*);

    Statement* parent();
    std::vector<std::pair<bool, Block_Obj>> slice_by_bubble(Block*);
    Statement* bubble(Directive*);
    Statement* bubble(At_Root_Block*);
    Statement* bubble(Media_Block*);
    Statement* bubble(Supports_Block*);

    Block* debubble(Block* children, Statement* parent = 0);
    Block* flatten(Block*);
    bool bubblable(Statement*);

    List* merge_media_queries(Media_Block*, Media_Block*);
    Media_Query* merge_media_query(Media_Query*, Media_Query*);

    // generic fallback
    template <typename U>
    Statement* fallback(U x)
    { return Cast<Statement>(x); }

    void append_block(Block*, Block*);
  };

}

#endif
