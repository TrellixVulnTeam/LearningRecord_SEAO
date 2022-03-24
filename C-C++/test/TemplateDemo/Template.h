#pragma once
#include <iostream>

// 模板范围特化
template <typename T>
void ref(T const& x) {
    std::cout << "x in ref(T const&): "
        << typeid(x).name() << std::endl;
}
template <typename T>
void nonref(T x) {
    std::cout << "x in nonref(T):  "
        << typeid(x).name() << std::endl;
}

// enable_if_t
struct T {
    enum { int_t, float_t } type;
    template <typename Integer,
        std::enable_if_t<std::is_integral<Integer>::value, bool> = true>
        T(Integer) : type(int_t) {}

    template <typename Floating,
        std::enable_if_t<std::is_floating_point<Floating>::value, bool> = true>
        T(Floating) : type(float_t) {} // OK
};

// C++ 17 结构化绑定 {
/*auto[fraction, remainder] = divide_remainder(16, 3);
std::cout << "16 / 3 is "
<< fraction << " with a remainder of "
<< remainder << '\n';*/
// C++ 17 结构化绑定 }

// C++ 17 使用折叠表达式实现辅助函数 {
// 实现一个函数，用于将所有参数进行累加
template<typename ... Ts>
inline auto sum(Ts ... ts) {
    return (ts + ...);
}

// 匹配范围内的单个元素
template <typename R, typename ... Ts>
inline auto matches(const R& range, Ts ... ts) {
    return (std::count(std::begin(range), std::end(range), ts) + ...);
}

// 检查所有参数是否在范围内
template <typename T, typename ... Ts>
inline bool within(T min, T max, Ts ...ts) {
    return ((min <= ts && ts <= max) && ...);
}

// 将多个元素推入vector中
template <typename T, typename ... Ts>
void insert_all(std::vector<T> &vec, Ts ... ts) {
    (vec.push_back(ts), ...);
}
// C++ 17 使用折叠表达式实现辅助函数 }

// C++ 17 std::unordered_map中使用自定义类型 {
struct coord {
    int x;
    int y;
};

bool operator==(const coord& l, const coord& r) {
    return l.x == r.x && l.y == r.y;
}

//namespace std {
//    template <>
//    struct hash<coord> {
//        using argument_type = coord;
//        using result_type = size_t;
//        result_type operator()(const argument_type& c) const {
//            return static_cast<result_type>(c.x)
//                + static_cast<result_type>(c.y);
//        }
//    };
//}

template <class _Kty>
struct my_hash_type {
    using argument_type = _Kty;
    using result_type = size_t;
    result_type operator()(const argument_type& c) const {
        return static_cast<result_type>(c.x)
            + static_cast<result_type>(c.y);
    }
};
// C++ 17 std::unordered_map中使用自定义类型 }

// C++ 17 使用Lambda为std::function添加多态性 {
template <typename C>
inline auto consumer(C& container) {
    return [&](auto value) {
        container.push_back(value);
    };
}

template <typename C>
inline void print(const C& c) {
    for (auto i : c) {
        std::cout << i << ", ";
    }
    std::cout << '\n';
}
// C++ 17 使用Lambda为std::function添加多态性 }

// 计数算法模板
template <typename InputIterator, typename T, typename F>
inline T accumulate(InputIterator first, InputIterator last, T init, F f) {
    for (; first != last; ++first) {
        init = f(init, *first);
    }
    return init;
}