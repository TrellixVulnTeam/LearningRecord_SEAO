#pragma once
#include <iostream>

// ģ�巶Χ�ػ�
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

// C++ 17 �ṹ���� {
/*auto[fraction, remainder] = divide_remainder(16, 3);
std::cout << "16 / 3 is "
<< fraction << " with a remainder of "
<< remainder << '\n';*/
// C++ 17 �ṹ���� }

// C++ 17 ʹ���۵����ʽʵ�ָ������� {
// ʵ��һ�����������ڽ����в��������ۼ�
template<typename ... Ts>
inline auto sum(Ts ... ts) {
    return (ts + ...);
}

// ƥ�䷶Χ�ڵĵ���Ԫ��
template <typename R, typename ... Ts>
inline auto matches(const R& range, Ts ... ts) {
    return (std::count(std::begin(range), std::end(range), ts) + ...);
}

// ������в����Ƿ��ڷ�Χ��
template <typename T, typename ... Ts>
inline bool within(T min, T max, Ts ...ts) {
    return ((min <= ts && ts <= max) && ...);
}

// �����Ԫ������vector��
template <typename T, typename ... Ts>
void insert_all(std::vector<T> &vec, Ts ... ts) {
    (vec.push_back(ts), ...);
}
// C++ 17 ʹ���۵����ʽʵ�ָ������� }

// C++ 17 std::unordered_map��ʹ���Զ������� {
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
// C++ 17 std::unordered_map��ʹ���Զ������� }

// C++ 17 ʹ��LambdaΪstd::function��Ӷ�̬�� {
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
// C++ 17 ʹ��LambdaΪstd::function��Ӷ�̬�� }

// �����㷨ģ��
template <typename InputIterator, typename T, typename F>
inline T accumulate(InputIterator first, InputIterator last, T init, F f) {
    for (; first != last; ++first) {
        init = f(init, *first);
    }
    return init;
}