#include "jq_core.h"

static VALUE rb_eJQ_Error;

static void jq_err_cb(void *data, jv msg) {
  VALUE errmsg;
  struct jq_container *p = (struct jq_container *) data;
  msg = jq_format_error(msg);

  errmsg = rb_str_new2(jv_string_value(msg));

  if (NIL_P(p->errmsg)) {
    p->errmsg = errmsg;
  } else {
    rb_str_concat(errmsg, rb_str_new2("\n"));
    rb_str_concat(errmsg, p->errmsg);
    p->errmsg = errmsg;
  }

  jv_free(msg);
}

static void rb_jq_free(struct jq_container *p) {
  xfree(p);
}

static VALUE rb_jq_alloc(VALUE klass) {
  struct jq_container *p;
  p = ALLOC(struct jq_container);
  p->jq = NULL;
  p->parser = NULL;
  p->closed = 1;
  p->errmsg = Qnil;
  return Data_Wrap_Struct(klass, 0, rb_jq_free, p);
}

static VALUE rb_jq_initialize(VALUE self, VALUE program) {
  struct jq_container *p;
  jq_state *jq;
  int compiled;

  Data_Get_Struct(self, struct jq_container, p);
  Check_Type(program, T_STRING);
  jq = jq_init();

  if (jq == NULL) {
    rb_raise(rb_eJQ_Error, "%s", strerror(errno));
  }

  jq_set_error_cb(jq, jq_err_cb, p);

  compiled = jq_compile(jq, RSTRING_PTR(program));

  if (!compiled) {
    jq_teardown(&jq);

    if (NIL_P(p->errmsg)) {
      rb_raise(rb_eJQ_Error, "compile error");
    } else {
      rb_raise(rb_eJQ_Error, "%s", RSTRING_PTR(p->errmsg));
    }
  }

  p->jq = jq;
  p->parser = NULL;
  p->closed = 0;
  p->errmsg = Qnil;

  return Qnil;
}

static VALUE rb_jq_close(VALUE self) {
  struct jq_container *p;
  Data_Get_Struct(self, struct jq_container, p);

  if (!p->closed) {
    jq_teardown(&p->jq);
    p->jq = NULL;
    p->parser = NULL;
    p->closed = 1;
    p->errmsg = Qnil;
  }

  return Qnil;
}

static void jq_process(jq_state *jq, jv value, VALUE (*proc)(), int *status, VALUE *errmsg) {
  jv result;
  jq_start(jq, value, 0);

  while (jv_is_valid(result = jq_next(jq))) {
    jv dumped = jv_dump_string(result, 0);
    const char *str = jv_string_value(dumped);

    if (*status == 0) {
      rb_protect(proc, rb_str_new2(str), status);
    }
    jv_free(dumped);
  }

  if (jv_invalid_has_msg(jv_copy(result))) {
    jv msg = jv_invalid_get_msg(result);
    *errmsg = rb_str_new2(jv_string_value(msg));
    jv_free(msg);
  } else {
    jv_free(result);
  }
}

static void jq_parse(jq_state *jq, struct jv_parser *parser, VALUE (*proc)(), int *status, VALUE *errmsg) {
  jv value;

  while (jv_is_valid(value = jv_parser_next(parser))) {
    if (*status == 0) {
      jq_process(jq, value, proc, status, errmsg);
    }
  }

  if (jv_invalid_has_msg(jv_copy(value))) {
    jv msg = jv_invalid_get_msg(value);
    *errmsg = rb_str_new2(jv_string_value(msg));
    jv_free(msg);
  } else {
    jv_free(value);
  }
}

static VALUE rb_jq_update(VALUE self, VALUE buf, VALUE v_is_partial) {
  struct jq_container *p;
  int is_partial = v_is_partial ? 1 : 0;
  int status = 0;
  VALUE errmsg = Qnil;

  if (!rb_block_given_p()) {
    rb_raise(rb_eArgError, "no block given");
  }

  Data_Get_Struct(self, struct jq_container, p);
  Check_Type(buf, T_STRING);

  if (!p->parser) {
    p->parser = jv_parser_new(0);
  }

  jv_parser_set_buf(p->parser, RSTRING_PTR(buf), RSTRING_LEN(buf), is_partial);
  jq_parse(p->jq, p->parser, rb_yield, &status, &errmsg);

  if (!is_partial) {
    jv_parser_free(p->parser);
    p->parser = NULL;
  }

  if (status != 0) {
    rb_jump_tag(status);
  }

  if (!NIL_P(errmsg)) {
    rb_raise(rb_eJQ_Error, "%s", RSTRING_PTR(errmsg));
  }

  return Qnil;
}

void Init_jq_core() {
  VALUE rb_mJQ = rb_define_module("JQ");
  VALUE rb_cJQ_Core = rb_define_class_under(rb_mJQ, "Core", rb_cObject);
  rb_eJQ_Error = rb_define_class_under(rb_mJQ, "Error", rb_eStandardError);
  rb_define_alloc_func(rb_cJQ_Core, rb_jq_alloc);
  rb_define_private_method(rb_cJQ_Core, "initialize", rb_jq_initialize, 1);
  rb_define_method(rb_cJQ_Core, "close", rb_jq_close, 0);
  rb_define_method(rb_cJQ_Core, "update", rb_jq_update, 2);
}
