package deque

import "base:builtin"
import "core:fmt"
import "core:mem"
import "core:testing"

// MIN_CAPACITY is the smallest capacity that deque may have. Must be power of 2
// for bitwise modulus: x % n == x & (n - 1).
MIN_CAPACITY :: 16

// Deque represents a single instance of the deque data structure. A Deque
// instance contains items of the type specified by the type argument.
//
// For example, to create a Deque that contains strings do one of the
// following:
//
//      d: Deque(string)
//      d := new(Deque(string))
//
// To create a Deque that will never resize to have space for less than 64
// items, specify a base capacity:
//
//	d: Deque(int)
//	set_base_cap(&d, 64)
//
// To ensure the Deque can store 1000 items without needing to resize while
// items are added:
//
//	grow(d, 1000)
//
// Any values supplied to set_base_cap and grow are rounded up to the nearest
// power of 2, since the Deque grows by powers of 2.

Deque :: struct($T: typeid) {
	buf:     []T,
	head:    int,
	tail:    int,
	count:   int,
	min_cap: int,
}

// cap returns the current capacity of the Deque. If d is nil, cap(d) is zero.
cap :: proc "contextless" (d: ^$D/Deque($T)) -> int {
	if d == nil {
		return 0
	}
	return builtin.len(d.buf)
}

// Len returns the number of elements currently stored in the queue. If d is
// nil, len(d) returns zero.
len :: proc "contextless" (d: ^$D/Deque($T)) -> int {
	if d == nil {
		return 0
	}
	return d.count
}

// push_front prepends an element to the front of the queue.
push_front :: proc(d: ^$D/Deque($T), elem: T) {
	grow_if_full(d)

	// Calculate new head position.
	d.head = prev(d, d.head)
	d.buf[d.head] = elem
	d.count += 1
}

// push_back appends an element to the back of the queue. Implements FIFO when
// elements are removed with pop_front, and LIFO when elements are removed with
// pop_back.
push_back :: proc(d: ^$D/Deque($T), elem: T) {
	grow_if_full(d)

	d.buf[d.tail] = elem
	// Calculate new tail position.
	d.tail = next(d, d.tail)
	d.count += 1
}

// pop_front removes and returns the element from the front of the queue.
// Implements FIFO when used with push_back. If the queue is empty, the call
// panics.
pop_front :: proc(d: ^$D/Deque($T)) -> T {
	if d.count <= 0 {
		panic("deque: pop_front() called on empty queue")
	}
	ret := d.buf[d.head]
	zero: T
	d.buf[d.head] = zero
	// Calculate new head position.
	d.head = next(d, d.head)
	d.count -= 1

	shrink_if_excess(d)
	return ret
}

// pop_back removes and returns the element from the back of the queue.
// Implements LIFO when used with push_back. If the queue is empty, the call
// panics.
pop_back :: proc(d: ^$D/Deque($T)) -> T {
	if d.count <= 0 {
		panic("deque: pop_back() called on empty queue")
	}

	// Calculate new tail position
	d.tail = prev(d, d.tail)

	// Remove value at tail.
	ret := d.buf[d.tail]
	zero: T
	d.buf[d.tail] = zero
	d.count -= 1

	shrink_if_excess(d)
	return ret
}

// front returns the element at the front of the queue. This is the element
// that would be returned by pop_front. This call panics if the queue is empty.
front :: proc(d: ^$D/Deque($T)) -> T {
	if d.count <= 0 {
		panic("deque: front() called when empty")
	}
	return d.buf[d.head]
}

// back returns the element at the back of the queue. This is the element that
// would be returned by pop_back. This call panics if the queue is empty.
back :: proc(d: ^$D/Deque($T)) -> T {
	if d.count <= 0 {
		panic("deque: back() called when empty")
	}
	return d.buf[prev(d, d.tail)]
}

// at returns the element at index i in the queue without removing the element
// from the queue. This method accepts only non-negative index values. at(0)
// refers to the first element and is the same as front(). at(Len()-1) refers
// to the last element and is the same as Back(). If the index is invalid, the
// call panics.
//
// The purpose of at is to allow Deque to serve as a more general purpose
// circular buffer, where items are only added to and removed from the ends of
// the deque, but may be read from any place within the deque. Consider the
// case of a fixed-size circular log buffer: A new entry is pushed onto one end
// and when full the oldest is popped from the other end. All the log entries
// in the buffer must be readable without altering the buffer contents.
at :: proc(d: ^$D/Deque($T), i: int) -> T {
	check_range(d, i)
	// bitwise modulus
	return d.buf[(d.head + i) & (builtin.len(d.buf) - 1)]
}

// set assigns the item to index i in the queue. set indexes the deque the same
// as at but perform the opposite operation. If the index is invalid, the call
// panics.
set :: proc(d: ^$D/Deque($T), i: int, item: T) {
	check_range(d, i)
	// bitwise modulus
	d.buf[(d.head + i) & (builtin.len(d.buf) - 1)] = item
}

// clear removes all elements from the queue, but retains the current capacity.
// This is useful when repeatedly reusing the queue at high frequency to avoid
// GC during reuse. The queue will not be resized smaller as long as items are
// only added. Only when items are removed is the queue subject to getting
// resized smaller.
clear :: proc(d: ^$D/Deque($T)) {
	if len(d) == 0 {
		return
	}
	head, tail := d.head, d.tail
	d.count = 0
	d.head = 0
	d.tail = 0

	if head >= tail {
		// [DEF....ABC]
		mem.zero_slice(d.buf[head:])
		head = 0
	}
	mem.zero_slice(d.buf[head:tail])
}
// grow grows deque's capacity, if necessary, to guarantee space for another n
// items. After grow(n), at least n items can be written to the deque without
// another allocation. If n is negative, grow panics.
grow :: proc(d: ^$D/Deque($T), n: int) {
	if n < 0 {
		panic("deque.grow: negative count")
	}
	c := cap(d)
	l := len(d)
	// If already big enough.
	if n <= c - l {
		return
	}

	if c == 0 {
		c = MIN_CAPACITY
	}

	new_len := l + n
	for c < new_len {
		c <<= 1
	}
	if l == 0 {
		d.buf = make([]T, c)
		d.head = 0
		d.tail = 0
	} else {
		resize(d, c)
	}
}

// rotate rotates the deque n steps front-to-back. If n is negative, rotates
// back-to-front. Having Deque provide rotate avoids resizing that could happen
// if implementing rotation using only Pop and Push methods. If len(&d) is one
// or less, or d is nil, then rotate does nothing.
rotate :: proc(d: ^$D/Deque($T), n: int) {
	if len(d) <= 1 {
		return
	}
	// Rotating a multiple of q.count is same as no rotation.
	n := n
	n %= d.count
	if n == 0 {
		return
	}

	mod_bits := builtin.len(d.buf) - 1
	// If no empty space in buffer, only move head and tail indexes.
	if d.head == d.tail {
		// Calculate new head and tail using bitwise modulus.
		d.head = (d.head + n) & mod_bits
		d.tail = d.head
		return
	}

	zero: T

	if n < 0 {
		// Rotate back to front.
		for ; n < 0; n += 1 {
			// Calculate new head and tail using bitwise modulus.
			d.head = (d.head - 1) & mod_bits
			d.tail = (d.tail - 1) & mod_bits
			// Put tail value at head and remove value at tail.
			d.buf[d.head] = d.buf[d.tail]
			d.buf[d.tail] = zero
		}
		return
	}

	// Rotate front to back.
	for ; n > 0; n -= 1 {
		// Put head value at tail and remove value at head.
		d.buf[d.tail] = d.buf[d.head]
		d.buf[d.head] = zero
		// Calculate new head and tail using bitwise modulus.
		d.head = (d.head + 1) & mod_bits
		d.tail = (d.tail + 1) & mod_bits
	}
}

// index returns the index into the Deque of the first item satisfying f(item),
// or -1 if none do. If q is nil, then -1 is always returned. Search is linear
// starting with index 0.
index :: proc(d: ^$D/Deque($T), f: proc(_: T) -> bool) -> int {
	if len(d) > 0 {
		mod_bits := builtin.len(d.buf) - 1
		for i := 0; i < d.count; i += 1 {
			if f(d.buf[(d.head + i) & mod_bits]) {
				return i
			}
		}
	}
	return -1
}

// rindex is the same as index, but searches from Back to Front. The index
// returned is from Front to Back, where index 0 is the index of the item
// returned by front().
rindex :: proc(d: ^$D/Deque($T), f: proc(_: T) -> bool) -> int {
	if len(d) > 0 {
		mod_bits := builtin.len(d.buf) - 1
		for i := d.count - 1; i >= 0; i -= 1 {
			if f(d.buf[(q.head + i) & mod_bits]) {
				return i
			}
		}
	}
	return -1
}

// insert is used to insert an element into the middle of the queue, before the
// element at the specified index. insert(0,e) is the same as push_front(e) and
// insert(Len(),e) is the same as push_back(e). Out of range indexes result in
// pushing the item onto the front of back of the deque.
//
// Important: Deque is optimized for O(1) operations at the ends of the queue,
// not for operations in the the middle. Complexity of this function is
// constant plus linear in the lesser of the distances between the index and
// either of the ends of the queue.
insert :: proc(d: ^$D/Deque($T), at: int, item: T) {
	if at <= 0 {
		push_front(d, item)
		return
	}
	if at >= len(d) {
		push_back(d, item)
		return
	}
	if at * 2 < d.count {
		push_front(d, item)
		front := d.head
		for i := 0; i < at; i += 1 {
			next := next(d, front)
			d.buf[front], d.buf[next] = d.buf[next], d.buf[front]
			front = next
		}
		return
	}
	swaps := d.count - at
	push_back(d, item)
	back := prev(d, d.tail)
	for i := 0; i < swaps; i += 1 {
		prev := prev(d, back)
		d.buf[back], d.buf[prev] = d.buf[prev], d.buf[back]
		back = prev
	}
}
// remove removes and returns an element from the middle of the queue, at the
// specified index. remove(0) is the same as pop_front() and remove(Len()-1) is
// the same as pop_back(). Accepts only non-negative index values, and panics if
// index is out of range.
//
// Important: Deque is optimized for O(1) operations at the ends of the queue,
// not for operations in the the middle. Complexity of this function is
// constant plus linear in the lesser of the distances between the index and
// either of the ends of the queue.
remove :: proc(d: ^$D/Deque($T), at: int) -> T {
	check_range(d, at)
	rm := (d.head + at) & (builtin.len(d.buf) - 1)
	if at * 2 < d.count {
		for i := 0; i < at; i += 1 {
			prev := prev(d, rm)
			d.buf[prev], d.buf[rm] = d.buf[rm], d.buf[prev]
			rm = prev
		}
		return pop_front(d)
	}
	swaps := d.count - at - 1
	for i := 0; i < swaps; i += 1 {
		next := next(d, rm)
		d.buf[rm], d.buf[next] = d.buf[next], d.buf[rm]
		rm = next
	}
	return pop_back(d)
}

// set_base_cap sets a base capacity so that at least the specified number of
// items can always be stored without resizing.
set_base_cap :: proc(d: ^$D/Deque($T), base_cap: int) {
	min_cap := MIN_CAPACITY
	for min_cap < baseCap {
		min_cap <<= 1
	}
	d.min_cap = min_cap
}
// swap exchanges the two values at idxA and idxB. It panics if either index is
// out of range.
swap :: proc(d: ^$D/Deque($T), idx_a: int, idx_b: int) {
	check_range(d, idx_a)
	check_range(d, idx_b)
	if idx_a == idx_b {
		return
	}

	real_a := (d.head + idx_a) & (builtin.len(d.buf) - 1)
	real_b := (d.head + idx_b) & (builtin.len(d.buf) - 1)
	d.buf[real_a], d.buf[real_b] = d.buf[real_b], d.buf[real_a]
}

destroy :: proc(d: ^$D/Deque($T)) {
	delete(d.buf)
}


// shrink_if_excess resize down if the buffer 1/4 full.
@(private)
shrink_if_excess :: proc(d: ^$D/Deque($T)) {
	if builtin.len(d.buf) > d.min_cap && (d.count << 2) == builtin.len(d.buf) {
		resize(d, d.count << 1)
	}
}

// grow_if_full resizes up if the buffer is full.
@(private)
grow_if_full :: proc(d: ^$D/Deque($T)) {
	if d.count != builtin.len(d.buf) {
		return
	}
	if builtin.len(d.buf) == 0 {
		if d.min_cap == 0 {
			d.min_cap = MIN_CAPACITY
		}
		d.buf = make([]T, d.min_cap)
		return
	}
	resize(d, d.count << 1)
}

// resize resizes the deque to fit exactly twice its current contents. This is
// used to grow the queue when it is full, and also to shrink it when it is
// only a quarter full.
@(private)
resize :: proc(d: ^$D/Deque($T), new_size: int) {
	old_buf := d.buf
	new_buf := make([]T, new_size)
	if d.tail > d.head {
		copy(new_buf, d.buf[d.head:d.tail])
	} else {
		n := copy(new_buf, d.buf[d.head:])
		copy(new_buf[n:], d.buf[:d.tail])
	}
	delete(old_buf)
	d.head = 0
	d.tail = d.count
	d.buf = new_buf
}

// prev returns the previous buffer position wrapping around buffer.
@(private)
prev :: proc(d: ^$D/Deque($T), i: int) -> int {
	return (i - 1) & (builtin.len(d.buf) - 1) // bitwise modulus
}
// next returns the next buffer position wrapping around buffer.
@(private)
next :: proc(d: ^$D/Deque($T), i: int) -> int {
	return (i + 1) & (builtin.len(d.buf) - 1) // bitwise modulus
}

@(private)
check_range :: proc(d: ^$D/Deque($T), i: int) {
	if i < 0 || i >= d.count {
		fmt.panicf("deque: index out of range %d with length %d", i, len(d))
	}
}

@(test)
test_cap :: proc(t: ^testing.T) {
	d: Deque(int)
	testing.expect(t, cap(&d) == 0)
}

@(test)
test_len :: proc(t: ^testing.T) {
	d: Deque(int)
	testing.expect(t, len(&d) == 0)
}

@(test)
test_create :: proc(t: ^testing.T) {
	{
		d: Deque(int)
		push_back(&d, 1)
		push_back(&d, 2)
		push_back(&d, 3)
		testing.expect(t, at(&d, 0) == 1)
		testing.expect(t, at(&d, 1) == 2)
		testing.expect(t, at(&d, 2) == 3)
		destroy(&d)
	}
	{
		d := new(Deque(int))
		push_back(d, 1)
		push_back(d, 2)
		push_back(d, 3)
		testing.expect(t, at(d, 0) == 1)
		testing.expect(t, at(d, 1) == 2)
		testing.expect(t, at(d, 2) == 3)
		destroy(d)
		free(d)
	}
}

@(test)
test_push_back :: proc(t: ^testing.T) {
	d: Deque(int)
	push_back(&d, 1)
	push_back(&d, 2)
	push_back(&d, 3)
	testing.expect(t, cap(&d) == MIN_CAPACITY)
	testing.expect(t, len(&d) == 3)
	destroy(&d)
}

@(test)
test_push_front :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	testing.expect(t, cap(&d) == MIN_CAPACITY)
	testing.expect(t, len(&d) == 3)
	destroy(&d)
}

@(test)
test_pop_front :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	testing.expect(t, pop_front(&d) == 3)
	testing.expect(t, pop_front(&d) == 2)
	testing.expect(t, pop_front(&d) == 1)
	testing.expect(t, len(&d) == 0)
	destroy(&d)
}

@(test)
test_pop_back :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	testing.expect(t, pop_back(&d) == 1)
	testing.expect(t, pop_back(&d) == 2)
	testing.expect(t, pop_back(&d) == 3)
	testing.expect(t, len(&d) == 0)
	destroy(&d)
}

@(test)
test_front_and_back :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	testing.expect(t, front(&d) == 3)
	testing.expect(t, len(&d) == 3)
	testing.expect(t, back(&d) == 1)
	testing.expect(t, len(&d) == 3)
	destroy(&d)
}

@(test)
test_at :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	testing.expect(t, at(&d, 0) == 3)
	testing.expect(t, at(&d, 1) == 2)
	testing.expect(t, at(&d, 2) == 1)
	destroy(&d)
}

@(test)
test_set :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	set(&d, 1, 50)
	testing.expect(t, at(&d, 1) == 50)
	destroy(&d)
}

@(test)
test_clear :: proc(t: ^testing.T) {
	d: Deque(int)
	push_front(&d, 1)
	push_front(&d, 2)
	push_front(&d, 3)
	clear(&d)
	testing.expect(t, len(&d) == 0)
	testing.expect(t, cap(&d) == MIN_CAPACITY)
	destroy(&d)
}

@(test)
test_grow :: proc(t: ^testing.T) {
	{
		d: Deque(int)
		grow(&d, 128)
		testing.expect(t, len(&d) == 0)
		testing.expect(t, cap(&d) == 128)
		destroy(&d)
	}
	{
		d: Deque(int)
		push_front(&d, 1)
		push_front(&d, 2)
		push_front(&d, 3)
		testing.expect(t, cap(&d) == MIN_CAPACITY)
		testing.expect(t, len(&d) == 3)
		grow(&d, 128)
		testing.expect(t, len(&d) == 3)
		testing.expect(t, cap(&d) == 128 * 2)
		destroy(&d)
	}
}

@(test)
test_rotate :: proc(t: ^testing.T) {
	d: Deque(int)
	push_back(&d, 1)
	push_back(&d, 2)
	push_back(&d, 3)
	rotate(&d, 0)
	testing.expect(t, at(&d, 0) == 1)
	rotate(&d, 1)
	testing.expect(t, at(&d, 0) == 2)
	rotate(&d, 2)
	testing.expect(t, at(&d, 0) == 1)
	destroy(&d)
}

@(test)
test_index :: proc(t: ^testing.T) {
	cmp_int :: proc(n: int) -> bool {
		return n == 3
	}

	d: Deque(int)
	push_back(&d, 1)
	push_back(&d, 2)
	push_back(&d, 3)

	testing.expect(t, index(&d, cmp_int) == 2)
	destroy(&d)
}

@(test)
test_rindex :: proc(t: ^testing.T) {
	cmp_string :: proc(s: string) -> bool {
		return s == "C"
	}

	d: Deque(string)
	push_back(&d, "A")
	push_back(&d, "B")
	push_back(&d, "C")

	testing.expect(t, index(&d, cmp_string) == 2)
	destroy(&d)
}

@(test)
test_insert :: proc(t: ^testing.T) {
	d: Deque(int)
	push_back(&d, 1)
	insert(&d, 1, 10)
	insert(&d, 2, 20)
	insert(&d, 10, 30)
	testing.expect(t, at(&d, 0) == 1)
	testing.expect(t, at(&d, 1) == 10)
	testing.expect(t, at(&d, 2) == 20)
	testing.expect(t, at(&d, 3) == 30)
	destroy(&d)
}

@(test)
test_remove :: proc(t: ^testing.T) {
	d: Deque(int)
	push_back(&d, 1)
	push_back(&d, 2)
	push_back(&d, 3)
	remove(&d, 1)
	testing.expect(t, at(&d, 0) == 1)
	testing.expect(t, at(&d, 1) == 3)
	remove(&d, 0)
	testing.expect(t, at(&d, 0) == 3)
	destroy(&d)
}

@(test)
test_swap :: proc(t: ^testing.T) {
	d: Deque(int)
	push_back(&d, 1)
	push_back(&d, 2)
	push_back(&d, 3)
	swap(&d, 0, 2)
	testing.expect(t, at(&d, 0) == 3)
	testing.expect(t, at(&d, 1) == 2)
	testing.expect(t, at(&d, 2) == 1)
	destroy(&d)
}
