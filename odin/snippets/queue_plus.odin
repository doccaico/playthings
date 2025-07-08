package queue_plus

import "base:runtime"
import "core:container/queue"
import "core:testing"

// $ odin test queue_plus.odin -file

swap :: proc(q: ^$Q/queue.Queue($T), idx_a: int, idx_b: int, loc := #caller_location) {
	runtime.bounds_check_error_loc(loc, idx_a, int(q.len))
	runtime.bounds_check_error_loc(loc, idx_b, int(q.len))
	if idx_a == idx_b {
		return
	}
	q.data[idx_a], q.data[idx_b] = q.data[idx_b], q.data[idx_a]
}

index :: proc(q: $Q/queue.Queue($T), f: proc(_: T) -> bool) -> int {
	if queue.len(q) > 0 {
		mod_bits := queue.len(q) - 1
		for i := 0; i < queue.len(q); i += 1 {
			if f(q.data[i & mod_bits]) {
				return i
			}
		}
	}
	return -1
}

rindex :: proc(q: $Q/queue.Queue($T), f: proc(_: T) -> bool) -> int {
	if queue.len(q) > 0 {
		mod_bits := queue.len(q) - 1
		for i := queue.len(q) - 1; i >= 0; i -= 1 {
			if f(q.data[i & mod_bits]) {
				return i
			}
		}
	}
	return -1
}

@(test)
test_push_front :: proc(t: ^testing.T) {
	q: queue.Queue(int)
	queue.init(&q)
	queue.push_front(&q, 1)
	queue.push_front(&q, 2)
	queue.push_front(&q, 3)
	testing.expect(t, queue.pop_front(&q) == 3)
	testing.expect(t, queue.pop_front(&q) == 2)
	testing.expect(t, queue.pop_front(&q) == 1)
	queue.destroy(&q)
}

@(test)
test_push_back :: proc(t: ^testing.T) {
	q: queue.Queue(int)
	queue.init(&q)
	queue.push_back(&q, 1)
	queue.push_back(&q, 2)
	queue.push_back(&q, 3)
	testing.expect(t, queue.pop_back(&q) == 3)
	testing.expect(t, queue.pop_back(&q) == 2)
	testing.expect(t, queue.pop_back(&q) == 1)
	queue.destroy(&q)
}

@(test)
test_swap :: proc(t: ^testing.T) {
	q: queue.Queue(int)
	queue.init(&q)
	queue.push_back(&q, 1)
	queue.push_back(&q, 2)
	queue.push_back(&q, 3)
	swap(&q, 0, 2)
	testing.expect(t, queue.get(&q, 0) == 3)
	testing.expect(t, queue.get(&q, 1) == 2)
	testing.expect(t, queue.get(&q, 2) == 1)
	queue.destroy(&q)
}

@(test)
test_index :: proc(t: ^testing.T) {
	cmp_three :: proc(n: int) -> bool {
		return n == 3
	}
	{
		q: queue.Queue(int)
		queue.init(&q)
		queue.push_back(&q, 1)
		queue.push_back(&q, 2)
		queue.push_back(&q, 3)
		testing.expect(t, index(q, cmp_three) == 2)
		queue.destroy(&q)
	}
	cmp_four :: proc(n: int) -> bool {
		return n == 4
	}
	{
		q: queue.Queue(int)
		queue.init(&q)
		queue.push_back(&q, 1)
		queue.push_back(&q, 2)
		queue.push_back(&q, 3)
		testing.expect(t, index(q, cmp_four) == -1)
		queue.destroy(&q)
	}
}

@(test)
test_rindex :: proc(t: ^testing.T) {
	cmp_three :: proc(n: int) -> bool {
		return n == 3
	}
	{
		q: queue.Queue(int)
		queue.init(&q)
		queue.push_back(&q, 1)
		queue.push_back(&q, 2)
		queue.push_back(&q, 3)
		testing.expect(t, index(q, cmp_three) == 2)
		queue.destroy(&q)
	}
	cmp_four :: proc(n: int) -> bool {
		return n == 4
	}
	{
		q: queue.Queue(int)
		queue.init(&q)
		queue.push_back(&q, 1)
		queue.push_back(&q, 2)
		queue.push_back(&q, 3)
		testing.expect(t, index(q, cmp_four) == -1)
		queue.destroy(&q)
	}
}
