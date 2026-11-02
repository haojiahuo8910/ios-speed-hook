#import <substrate.h>
#import <Foundation/Foundation.h>

// 声明原 Unity set_timeScale 函数指针
static void (*orig_SetTimeScale)(float value);

// 自定义 Hook 拦截函数
void my_SetTimeScale(float value) {
    if (value <= 0.0f) {
        // 当游戏触发弹窗或暂停（timeScale 为 0）时，严格执行 0，彻底冻结时间
        orig_SetTimeScale(0.0f);
    } else {
        // 正常游戏时，应用你的自定义加速倍率（例如 3.0 倍）
        orig_SetTimeScale(value * 3.0f); 
    }
}

__attribute__((constructor)) static void initialize() {
    // 查找并 Hook Unity 的时间缩放方法
    MSHookFunction(
        (void *)MSFindSymbol(NULL, "UnityEngine_Time__set_timeScale"), 
        (void *)my_SetTimeScale, 
        (void **)&orig_SetTimeScale
    );
}
