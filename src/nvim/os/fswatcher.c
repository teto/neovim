#include "nvim/api/private/helpers.h"
#include "nvim/lua/executor.h"


// TODO we might want to toggle
// buf->b_saving = true; via a flag


void
watcher_start(buf_T *buf)
{
  // buf->b_ffname
  if (buf->b_luafd_watcher != LUA_NOREF) {
    //
    Error err = ERROR_INIT;
    FIXED_TEMP_ARRAY(args, 2);
    args.items[0] = BUFFER_OBJ(buf->handle);
    args.items[1] = INTEGER_OBJ(display_tick);

    // Object
    executor_exec_lua_cb(buf->b_luafd_watcher, "watch", args,
                            false, &err);

    if (ERROR_SET(&err)) {
      ELOG("error in starting watcher: %s", err.msg);
      api_clear_error(&err);
    }
  }
}

void
watcher_stop(buf_T *buf)
{

  // // disable file watching
  // // (void)eval_call_provider("watcher", "stop", args);
  // watcher_stop(buf);
  // buf->b_ffname

  if (buf->b_luafd_watcher != LUA_NOREF) {
    //
    Error err = ERROR_INIT;
    FIXED_TEMP_ARRAY(args, 2);
    DLOG("buf->b_ffname is...");
    DLOG("buf->b_ffname = %s", buf->b_ffname);
    args.items[0] = STRING_OBJ(buf->b_ffname);
    // args.items[1] = INTEGER_OBJ(display_tick);

    // Object
    executor_exec_lua_cb(buf->b_luafd_watcher, "stop", args,
                            false, &err);

    if (ERROR_SET(&err)) {
      ELOG("error in stopping watcher: %s", err.msg);
      api_clear_error(&err);
    }
  }

}
