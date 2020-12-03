// TemplateDemo.cpp : �������̨Ӧ�ó������ڵ㡣
//

#include <string>
#include <vector>
#include <list>
#include <deque>
#include <set>
#include <map>
#include <unordered_set>
#include <unordered_map>
#include <iterator>
#include <functional>
#include <algorithm>
#include "Template.h"

int main() {
    ref("hello");
    nonref("hello");

    {
        // C++ 17 �ṹ���� {
        struct employee {
            unsigned id;
            std::string name;
            std::string role;
            unsigned salary;
        };

        std::vector<employee> employees{
            /* Initialized from somewhere */
            {1, "a", "boss", 10000}
        };

        for (const auto& [id, name, role, salary] : employees) {
            std::cout << "Name: " << name
                << "Role: " << role
                << "Salary: " << salary << '\n';
        }
        // C++ 17 �ṹ���� }
    }

    {
        // C++ 17 ʹ���۵����ʽ {
        int the_sum{ sum(1, 2, 3, 4, 5) }; // value: 15

        std::string a{ "Hello " };
        std::string b{ "World" };

        std::cout << sum(a, b) << '\n'; // output: Hello World

        within(10, 20, 1, 15, 30); // --> false
        within(10, 20, 11, 12, 13); // --> true
        within(5.0, 5.5, 5.1, 5.2, 5.3); // --> true

        std::string aaa{ "aaa" };
        std::string bcd{ "bcd" };
        std::string def{ "def" };
        std::string zzz{ "zzz" };

        within(aaa, zzz, bcd, def); // --> true
        within(aaa, def, bcd, zzz); // --> false

        std::vector<int> v{ 1, 2, 3 };
        insert_all(v, 4, 5, 6);
        // C++ 17 ʹ���۵����ʽ }
    }

    {
        // C++ 17 ������������������if��switch������ {
        int num = 5;
        switch (int flag = 5 / 2; flag > 0) {
        case 1: break;
        case 2: break;
        case 3: break;
        default:break;
        }

        /*if (std::lock_guard<std::mutex> lg{ my_mutex }; some_condition) {
            // Do something
        }

        if (auto shared_pointer(weak_pointer.lock()); shared_pointer != nullptr) {
            // Yes, the shared object does still exist
        }
        else {
            // shared_pointer var is accessible, but a null pointer
        }
        // shared_pointer is not accessible any longer
        */
        // C++ 17 ������������������if��switch������ }
    }

    {
        // C++ 17 std::unordered_map��ʹ���Զ������� {
        std::unordered_map<coord, int, my_hash_type<coord>> m{
            { {0, 0}, 1},
            { {0, 1}, 2},
            { {2, 1}, 3}
        };
        for (const auto& [key, value] : m) {
            std::cout << "{(" << key.x << ", " << key.y
                << "): " << value << "} ";
        }
        std::cout << '\n';
        // C++ 17 std::unordered_map��ʹ���Զ������� }
    }

    {
        // ���������
        std::list<int> l{ 1, 2, 3, 4, 5 };
        std::copy(l.rbegin(), l.rend(), std::ostream_iterator<int>{std::cout, ", "});
        std::cout << '\n';

        // ����û�ж��巴�������������������ʹ��make_reverse_iteratorת��
        std::copy(std::make_reverse_iterator(l.end()), std::make_reverse_iterator(l.begin()), std::ostream_iterator<int>{std::cout, ", "});
        std::cout << '\n';
    }

    {
        // C++ 17 ʹ��LambdaΪstd::function��Ӷ�̬�� {
        std::deque<int> d;
        std::list<int> l;
        std::vector<int> v;

        const std::vector<std::function<void(int)>> consumers
        { consumer(d), consumer(l), consumer(v) };

        for (size_t i{ 0 }; i < 10; ++i) {
            for (auto&& consume : consumers) {
                consume(i);
            }
        }

        print(d);
        print(l);
        print(v);
        // C++ 17 ʹ��LambdaΪstd::function��Ӷ�̬�� }


    }

    return 0;
}

